local control = require("ui.control")
local border = require("ui.border")
local button = require("ui.button")
local label = require("ui.label")
local stackPanel = require("ui.stackPanel")
local command = require("ui.interaction.command")


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
		stackPanel,
		horizontalAlignment = "start",
		verticalAlignment = "center",
		orientation = "vertical",
		children = {
			{
				button,
				text = "Foobar",
				margin = { 0, 5, 0, 5 },
				command = comm1
			},
			{
				button,
				text = "Eggspam",
				margin = { 0, 5, 0, 5 },
				command = comm2
			}
		}
	}
}