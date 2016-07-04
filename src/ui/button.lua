local control = require("ui.control")
local class = require("misc.class")

local button = class("button", control)

function button.new(...)
	return {
		style = require("ui.styles.button")
	}
end

return button