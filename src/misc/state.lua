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

exit = function(state)
	if state.exit then
		state:exit()
	end
end

enter = function(state)
	if state == nullstate then
		error("Tried to pop last state on the stack!")
	end
	
	if not initialized[state] then
		initialized[state] = true
		if state.init then
			state:init()
		end
	end
	
	if state.enter then
		state:enter()
	end
end

return state