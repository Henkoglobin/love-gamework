local border = require("ui.border")
local label = require("ui.label")
local templateBinding = require("ui.bindings.templateBinding")

return {
	border,
	backgroundColor = { 128, 128, 128 },
	padding = { 40, 40, 40, 40 },
	content = {
		label,
		horizontalAlignment = "center",
		verticalAlignment = "center",
		text = {templateBinding, path = "text" }
	}
}