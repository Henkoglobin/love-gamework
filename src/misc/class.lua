local tableutil = require("misc.tableutil")
local object = require("misc.object")

local class = setmetatable({}, {
	__call = function(self, ...)
		return self.new(...)
	end
})
class.__index = class

function class.new(name, inherit)
	inherit = inherit or object
	local newClass = setmetatable({}, inherit)
	inherit.__call = function(self, proto, ...)
		local inst
		local parent = getmetatable(self)

		if class.isClass(parent) then
			inst = parent(proto, ...)
		else
			inst = tableutil.copy(proto or {})
		end

		if self.new then
			inst = tableutil.merge(inst, self.new(proto, ...))
		end

		return setmetatable(inst, self)
	end

	newClass.__type = name
	newClass.__tostring = function(self)
		return ("%s { } : %s"):format(newClass.__type, tostring(getmetatable(self)))
	end

	if inherit and type(inherit.__index) == "function" then
--if DEBUG
		print(("%s will have a custom __index"):format(name))
--endif

		newClass.__index = inherit.__index
	else
		newClass.__index = newClass
	end

	if inherit and inherit.__newindex then
--if DEBUG
		print(("%s will have a custom __newindex"):format(name))
--endif

		newClass.__newindex = function(self, key, value)
			inherit.__newindex(self, key, value)
		end
	end
	return newClass
end

function class.isClass(value)
	local mt = getmetatable(value)
	return mt and rawget(mt, "__call") and rawget(value, "__type")
end

local propertyIndex, propertyNewIndex
function class.property(cls, name, config)
--if DEBUG
	print(("Creating property %s for %s"):format(name, cls.__type))
--endif
	local props = rawget(cls, "__properties")
	if not props then
		rawset(cls, "__properties", {})
	end

	cls.__properties[name] = config
	cls.__index = propertyIndex
	if config.set then
--if DEBUG
		print(("Setting __newindex on %s.%s because of setter!"):format(cls.__type, name))
--endif

		cls.__newindex = propertyNewIndex
	end
end

local findProperty
propertyIndex = function(self, key)
	local prop = findProperty(self, key)

	if prop then
		return prop.get(self)
	else
		return getmetatable(self)[key]
	end
end

propertyNewIndex = function(self, key, value)
	local prop = findProperty(self, key)

	if prop then
		prop.set(self, value)
	else
		rawset(self, key, value)
	end
end

findProperty = function(tbl, property)
	local mt = getmetatable(tbl)
	if mt then
		local props = rawget(mt, "__properties")
		if props and props[property] then
			return props[property]
		end

		return findProperty(mt, property)
	end
end

return class
