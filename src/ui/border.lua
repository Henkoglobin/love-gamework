local class = require("misc.class")
local control = require("ui.control")

local border = class(control)

function border.new()
	return {
		__type = "border"
	}
end

function border:onRender(x, y, width, height)
	local offset = self.borderWidth
	
	love.graphics.push("all")
	love.graphics.setLineWidth(offset)
	love.graphics.setColor(self.borderColor)
	love.graphics.rectangle("line", x + offset / 2, y + offset / 2, width - offset, height - offset)
	
	love.graphics.setColor(self.backgroundColor)
	love.graphics.rectangle("fill", x + offset, y + offset, width - 2 * offset, height - 2 * offset)
	love.graphics.pop()
end

return border