local class = require("misc.class")

local mock = class("mock")

local function toOrdinary(number)
	if number == 1 then
		return "1st"
	elseif number == 2 then
		return "2nd"
	elseif number == 3 then
		return "3rd"
	else
		return ("%dth"):format(number)
	end
end

local unpack = table.unpack or unpack
function mock.new(calls)
	local obj = {}
	for method, invocations in pairs(calls) do
		obj[method] = function(self, ...)
			if type(invocations) == "table" then
				local parameters = {...}
				local expectedParameters = table.remove(invocations, 1)
				if not expectedParameters then
					error("Invocation list has been exhausted")
				end
				
				for index, parameter in pairs(parameters) do
					assert(parameter == expectedParameters[index], 
						("Unexpected %s value '%s' (expected: '%s') for call to %s")
							: format(toOrdinary(index), parameter, expectedParameters[index], method))
				end
				
				return unpack(expectedParameters.ret or {})
			else
				return invocations(...)
			end
		end
	end
	
	return { 
		calls = calls, 
		object = setmetatable(obj, {
			__index = function(self, key)
				print(("Unexpected index to table with key %s"):format(key))
				return setmetatable({ __name = key }, {
					__call = function(self, ...)
						print(("Unexpected method call to %s"):format(self.__name))
					end
				})
			end
		})
	}
end

function mock:assertExhausted()
	for method, invocations in pairs(self.calls) do
		if type(invocations) == "table" then
			assert(#invocations == 0, ("Method %s has %d calls left"):format(method, #invocations))
		end
	end
end

return mock