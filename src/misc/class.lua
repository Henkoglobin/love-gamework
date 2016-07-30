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
	newClass.__index = newClass
	newClass.__type = name
	newClass.__tostring = function(self)
		return ("%s { } : %s"):format(newClass.__type, tostring(getmetatable(self)))
	end
	return newClass
end

function class.isClass(value)
	local mt = getmetatable(value)
	return mt and rawget(mt, "__call") and rawget(value, "__type")
end

local propertyIndex, propertyNewIndex
function class.property(cls, name, config)
	print(("Creating property %s for %s"):format(name, cls.__type))
	local props = rawget(cls, "__properties")
	if not props then
		rawset(cls, "__properties", {})
	end

	cls.__properties[name] = config
	cls.__index = propertyIndex
	cls.__newindex = propertyNewIndex
end

propertyIndex = function(self, key)
	local props = rawget(getmetatable(self), "__properties")
	local prop = props and props[key]

	if prop then
		return prop.get(self)
	else
		return getmetatable(self)[key]
	end
end

propertyNewIndex = function(self, key, value)
	local props = rawget(getmetatable(self), "__properties")
	local prop = props and props[key]

	if prop then
		prop.set(self, value)
	else
		rawset(self, key, value)
	end
end

return class
