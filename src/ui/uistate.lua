local parser = require("ui.parser")

local uistate = setmetatable({}, {
	__call = function(self, ...)
		return setmetatable(self.new(...), self)
	end
})
uistate.__index = uistate

function uistate.new(content)
	return {
		content = parser.parse(content),
		needsMeasure = true
	}
end

function uistate:draw()
	local width, height = love.graphics.getWidth(), love.graphics.getHeight()

	if self.needsMeasure then
		self.content.parent = self
		self.content:measure(width, height)
		self.content:arrange(0, 0, width, height)
		self.needsMeasure = false
	end

	self.content:render(0, 0, width, height)
end

function uistate:touchreleased(id, x, y, dx, dy, pressure)
	self.content:touch(id, x, y, dx, dy, pressure)
end

function uistate:invalidate()
	self.needsMeasure = true
end

return uistate
