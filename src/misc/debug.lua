local debug = {}

local stream = {}
local enabled = true

function debug.append(line)
	if type(line) == "function" then
		table.insert(stream, line)
	else
		-- if line is not a function, wrap it
		table.insert(stream, function() return tostring(line) end)
	end
	
	return stream[#stream]
end

function debug.remove(func)
	for k, v in pairs(stream) do
		if v == func then
			table.remove(stream, k)
			return true
		end
	end
	
	return false
end

function debug.get()
	local result = {}
	for _, func in ipairs(stream) do
		table.insert(result, func())
	end
	
	return table.concat(result, "\n")
end

function debug.isEnabled()
	return enabled
end

function debug.enable()
	enabled = true
end

function debug.disable()
	enabled = false
end

return debug