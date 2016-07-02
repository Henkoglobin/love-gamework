local control = require("ui.control")
local class = require("misc.class")

local button = class(control)

function button.new(...)
	return {
		style = require("ui.styles.button")
	}
end

return button