local serialize
serialize = function(val, name, skipnewlines, depth, seen)
	seen = seen or {}
	if (type(skipnewlines) == "number") or (type(depth) == "boolean") then
		local tmp = skipnewlines
		depth = skipnewlines or 0
		skipnewlines = tmp or false
	else
		depth = depth or 0
	end

	local tmp = string.rep("   ", depth)

	if name and type(name) == "string" then 
		tmp = tmp .. name .. " = "
	elseif name and type(name) == "number" then
		tmp = tmp .. "[" .. tostring(name) .. "]" .. " = "
	elseif name then
		error(("Only strings and numbers are supported as keys (is: %s)"):format(type(name)))
	end

	if type(val) == "table" then
		if seen[val] then
			--error(("Cycles are not supported (in %s)"):format(name))
		end
		
		seen[val] = true
		tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")

		for k, v in pairs(val) do
			if type(k) ~= "string" or not k:match("^__") then
				tmp =  tmp .. serialize(v, k, skipnewlines, depth + 1, seen) .. "," .. (not skipnewlines and "\n" or "")
			end
		end

		tmp = tmp .. string.rep("   ", depth) .. "}"
	elseif type(val) == "number" then
		tmp = tmp .. tostring(val)
	elseif type(val) == "string" then
		tmp = tmp .. string.format("%q", val)
	elseif type(val) == "boolean" then
		tmp = tmp .. tostring(val)
	elseif type(val) == "function" then
		--tmp = tmp .. "loadstring(" .. serialize(string.dump(val)) .. ")"
	else
		error(("The type %s is not supported."):format(type(val)))
	end

	return tmp
end

return serialize