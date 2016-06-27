local tableutil = require("misc.tableutil")

local class = setmetatable({}, {
	__call = function(self, ...)
		return self.new(...)
	end
})
class.__index = class

local isClass
function class.new(inherit)
	inherit = inherit or {}
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
	return newClass
end

function isClass(value)
	local mt = getmetatable(value)
	return mt and mt.__call
end

return class