local debug = {}

local enabled = true

local static = {}
local wtf = {}
local i = {}
local d = {}
local v = {}

local config = {
	static = "*",
	wtf = 4,
	i = 5,
	d = 5,
	v = 5
}

function debug.configure(conf)
	config = {
		static = conf.static or config.static,
		wtf = conf.wtf or conf.e or config.wtf,
		i = conf.i or config.i,
		d = conf.d or config.d,
		v = conf.c or config.v
	}
end

function debug.static(line)
	if type(line) == "function" then
		table.insert(static, line)
	else
		-- if line is not a function, wrap it
		table.insert(static, function() return tostring(line) end)
	end

	return static[#static]
end

function debug.remove(func)
	for k, v in pairs(static) do
		if v == func then
			table.remove(static, k)
			return true
		end
	end

	return false
end

local log
function debug.wtf(line)
	log(wtf, config.wtf, line)
end

function debug.e(line)
	debug.wtf(line)
end

function debug.i(line)
	log(i, config.i, line)
end

function debug.d(line)
	log(d, config.d, line)
end

function debug.v(line)
	log(v, config.v, line)
end

local clean
log = function(stream, streamconf, line)
	if enabled then
		table.insert(stream, line)
		clean(stream, streamconf)
	end
end

clean = function(stream, streamconf)
	if streamconf == "*" then 
		return 
	end

	while #stream > streamconf do
		table.remove(stream, 1)
	end
end

function debug.get()
	local result = {}

	local bound = config.static == "*" and #static or math.min(config.static, #static)
	for j = 1, bound do
		table.insert(result, static[j]())
	end

	for _, stream in ipairs({ wtf, i, d, v }) do
		for _, line in ipairs(stream) do
			table.insert(result, line)
		end
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