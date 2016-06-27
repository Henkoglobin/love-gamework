local class = require("misc.class")
local control = require("ui.control")

local border = class(control)

function border.new()
	return {}
end

function border:onRender(x, y, width, height)
	local color = self.borderColor
	local offset = self.borderWidth
	
	love.graphics.setLineWidth(offset)
	love.graphics.setColor(color[1], color[2], color[3])
	love.graphics.rectangle("line", x + offset / 2, y + offset / 2, width - offset, height - offset)
	
	color = self.backgroundColor
	love.graphics.setColor(color[1], color[2], color[3])
	love.graphics.rectangle("fill", x + offset, y + offset, width - 2 * offset, height - 2 * offset)
end

return border