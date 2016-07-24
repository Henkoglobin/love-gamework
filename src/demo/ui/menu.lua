local control = require("ui.control")
local border = require("ui.border")
local button = require("ui.button")
local label = require("ui.label")
local stackPanel = require("ui.stackPanel")
local command = require("ui.interaction.command")
local grid = require("ui.grid")


local foo = true
local comm1, comm2

comm1 = command{
	execute = function()
		foo = not foo
		comm1:raiseCanExecuteChanged()
		comm2:raiseCanExecuteChanged()
	end,
	canExecute = function() return foo end
}
comm2 = command{
	execute = function()
		foo = not foo
		comm1:raiseCanExecuteChanged()
		comm2:raiseCanExecuteChanged()
	end,
	canExecute = function() return not foo end
}


return {
	border, 
	horizontalAlignment = "stretch",
	verticalAlignment = "stretch",
	content = {
		grid,
		rows = {
			{ height = 100 },
			{ height = "*" },
			{ height = "auto" }
		},
		columns = {
			{ width = 100 },
			{ width = "*" },
			{ width = "auto" }
		},
		children = {
			{ label, ["grid.row"] = 1, ["grid.column"] = 1, text = "1-1" },
			{ label, ["grid.row"] = 1, ["grid.column"] = 2, text = "1-2" },
			{ label, ["grid.row"] = 1, ["grid.column"] = 3, text = "1-3" },
			
			{ label, ["grid.row"] = 2, ["grid.column"] = 1, text = "2-1" },
			{ label, ["grid.row"] = 2, ["grid.column"] = 2, text = "2-2" },
			{ label, ["grid.row"] = 2, ["grid.column"] = 3, text = "2-3" },
			
			{ label, ["grid.row"] = 3, ["grid.column"] = 1, text = "3-1", verticalAlignment = "end" },
			{ label, ["grid.row"] = 3, ["grid.column"] = 2, text = "3-2", verticalAlignment = "end" },
			{ label, ["grid.row"] = 3, ["grid.column"] = 3, text = "3-3", verticalAlignment = "end" }
		}
	}
}