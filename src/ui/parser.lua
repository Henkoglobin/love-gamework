local object = require("misc.object")
local binding = require("ui.bindings.bindingBase")
local serialize = require("misc.serialize")

local parser = {}

function parser.parse(input)
	local t = input[1] or input.__type
	local instance
	local instanceFromClass = false
	
	if type(t) == "table" and getmetatable(t) and getmetatable(t).__call then
		instanceFromClass = true
		instance = t()
	elseif type(t) == "table" then
		instance = { }
	else
		return input
	end
	
	for prop, value in pairs(input) do
		if (not instanceFromClass or prop ~= 1) and (type(prop) ~= "string" or not prop:find("^__")) then
			if type(value) == "table" then
				value = parser.parse(value)
				if object.isInstanceOf(value, binding) then
					instance:addBinding(prop, value)
				else
					instance[prop] = value
				end
			else
				instance[prop] = value
			end
		end
	end
	
	return instance
end

return parser