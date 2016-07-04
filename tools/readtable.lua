#! /usr/bin/lua

local function main(infile, key)
	if infile ~= "-" then
		io.input(infile)
	end
	
	local stream = io.read("*a")
	local chunk, err = loadstring(stream)
	
	if chunk then
		local t = chunk()
		local value = t
		for subkey in key:gmatch("[^%.]+") do
			value = value[subkey]
		end
		
		io.write(value)
	else
		io.stderr:write(err)
	end
end

main(...)