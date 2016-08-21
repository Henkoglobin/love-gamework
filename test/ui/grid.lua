local mock = require("test.mock")
local grid = require("src.ui.grid")

local leftMock = mock({
	measure = {
		{ 100, 480 },
		{ 100, 480 }
	},
	setParent = function() end
})
leftMock.object["grid.row"] = 1
leftMock.object["grid.column"] = 1

local centerMock = mock({
	measure = {
		{ 440, 480 },
		{ 440, 480 }
	},
	setParent = function() end
})
centerMock.object["grid.row"] = 1
centerMock.object["grid.column"] = 2

local rightMock = mock({
	measure = {
		{ 100, 480 },
		{ 100, 480 }
	},
	setParent = function() end
})
rightMock.object["grid.row"] = 1
rightMock.object["grid.column"] = 3

local testGrid = grid()
grid.columns = {
	{ width = 100 },
	{ width = "*" },
	{ width = 100 }
}

grid.rows = {
	{ height = "*" }
}

grid.children = {
	leftMock.object, centerMock.object, rightMock.object
}

testGrid:measure(640, 480)
leftMock:assertExhausted()
centerMock:assertExhausted()
rightMock:assertExhausted()