local ldebug = require("misc.debug")

local state = {}

local nullstate = {}
local initialized = {}
local stack = { nullstate }

local exit, enter
function state.pop()
	local oldstate = table.remove(stack)
	exit(oldstate)
	
	local newstate = stack[#stack]
	enter(newstate)
end

function state.push(newstate)
	local oldstate = stack[#stack]
	exit(oldstate)
	
	table.insert(stack, newstate)
	enter(newstate)
end

function state.get()
	return stack[#stack]
end

local getname
enter = function(state)
	if state == nullstate then
		error("Tried to pop last state on the stack!")
	end
	
	if not initialized[state] then
		initialized[state] = true
		if state.init then
			ldebug.i(("Initializing state %s"):format(getname(state)))
			state:init()
		end
	end
	
	ldebug.i(("Entering state %s"):format(getname(state)))
	if state.enter then
		state:enter()
	end
end

exit = function(state)
	ldebug.i(("Exiting state %s"):format(getname(state)))
	if state.exit then
		state:exit()
	end
end

getname = function(state)
	if state.name then
		return state.name
	else
		local hash = tostring(state):match("^table: (.+)$")
		if hash then
			return ("Unknown State <%s>"):format(hash)
		end
	end
	
	return tostring(state)
end

return state