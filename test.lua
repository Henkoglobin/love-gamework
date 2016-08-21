package.path = package.path .. ";./src/?.lua"

local mock = require("test.mock")

local mymock = mock({
	add = {
		{ 1, 2, ret = { 3 } },
		{ 4, 6, ret = { 10 } }
	},
	sub = function(a, b) return a - b end
})

assert(mymock.object:add(1, 2) == 3)
assert(mymock.object:add(4, 6) == 10)
assert(mymock.object:sub(7, 3) == 4)
assert(mymock.object:sub(1, 2) == -1)

mymock:assertExhausted()

require("test.ui.grid")