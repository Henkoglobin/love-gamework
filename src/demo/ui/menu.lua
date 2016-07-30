local border = require("ui.border")
local label = require("ui.label")
local grid = require("ui.grid")
local viewmodel = require("demo.ui.viewmodel")
local dataBinding = require("ui.bindings.dataBinding")

return {
	border, 
	dataContext = {
		viewmodel,
		text1 = "Foobar",
		text2 = "Eggspam"
	},
	horizontalAlignment = "stretch",
	verticalAlignment = "stretch",
	content = {
		grid,
		rows = {
			{ height = 300 },
			{ height = "*" },
			{ height = "auto" }
		},
		columns = {
			{ width = 100 },
			{ width = "*" },
			{ width = "auto" }
		},
		children = {
			{ label, ["grid.row"] = 1, ["grid.column"] = 1, text = "1-1", verticalAlignment = "start", horizontalAlignment = "start" },
			{ label, ["grid.row"] = 1, ["grid.column"] = 2, text = "1-2", verticalAlignment = "start", horizontalAlignment = "start" },
			{ label, ["grid.row"] = 1, ["grid.column"] = 3, text = "1-3", verticalAlignment = "start", horizontalAlignment = "start" },
			
			{ label, ["grid.row"] = 2, ["grid.column"] = 1, text = "2-1", verticalAlignment = "center", horizontalAlignment = "center" },
			{ label, ["grid.row"] = 2, ["grid.column"] = 2, text = { dataBinding, path = "text1" }, verticalAlignment = "center", horizontalAlignment = "center" },
			{ label, ["grid.row"] = 2, ["grid.column"] = 3, text = "2-3", verticalAlignment = "center", horizontalAlignment = "center" },
			
			{ label, ["grid.row"] = 3, ["grid.column"] = 1, text = "3-1", verticalAlignment = "end", horizontalAlignment = "end" },
			{ label, ["grid.row"] = 3, ["grid.column"] = 2, text = "3-2", verticalAlignment = "end", horizontalAlignment = "end" },
			{ label, ["grid.row"] = 3, ["grid.column"] = 3, text = { dataBinding, path = "text2" }, verticalAlignment = "end", horizontalAlignment = "end" }
		}
	}
}