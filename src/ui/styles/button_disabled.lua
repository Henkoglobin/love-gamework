local border = require("ui.border")
local label = require("ui.label")
local templateBinding = require("ui.bindings.templateBinding")

return {
	border,
	backgroundColor = { 64, 64, 64 },
	padding = { 40, 40, 40, 40 },
	content = {
		label,
		horizontalAlignment = "center",
		verticalAlignment = "center",
		text = {templateBinding, path = "text" },
		foregroundColor = { 192, 192, 192 }
	}
}