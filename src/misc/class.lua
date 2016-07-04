local tableutil = require("misc.tableutil")
local object = require("misc.object")

local class = setmetatable({}, {
	__call = function(self, ...)
		return self.new(...)
	end
})
class.__index = class

local isClass
function class.new(name, inherit)
	inherit = inherit or object
	local newClass = setmetatable({}, inherit)
	inherit.__call = function(self, proto, ...)
		local inst
		
		local parent = getmetatable(self)
		if isClass(parent) then
			inst = parent(proto, ...)
		else
			inst = tableutil.copy(proto or {})
		end
		
		if self.new then
			inst = tableutil.merge(inst, self.new(...))
		end
		
		return setmetatable(inst, self)
	end
	newClass.__index = newClass
	newClass.__type = name
	return newClass
end

isClass = function(value)
	local mt = getmetatable(value)
	return mt and mt.__call
end

return class