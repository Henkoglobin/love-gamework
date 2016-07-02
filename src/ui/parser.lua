local parser = {}

function parser.parse(input)
	local t = input[1] or input.__type
	local instance
	
	if type(t) == "table" and getmetatable(t) and getmetatable(t).__call then
		instance = t()
	elseif type(t) == "table" then
		instance = {}
	else
		return input
	end
	
	for prop, value in pairs(input) do
		if type(prop) ~= "string" or not prop:find("^__") then
			if type(value) == "table" then
				value = parser.parse(value)
			end
			instance[prop] = value
		end
	end
	
	return instance
end

return parser