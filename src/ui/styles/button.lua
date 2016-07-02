local border = require("ui.border")
local label = require("ui.label")

return {
	border,
	backgroundColor = { 100, 149, 237 },
	padding = { 40, 40, 40, 40 },
	content = {
		label,
		horizontalAlignment = "center",
		verticalAlignment = "center",
		text = "Button 1"
	}
}