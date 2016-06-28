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
		self.content:measure(width, height)
		self.content:arrange(0, 0, width, height)
	end
	
	self.content:render(0, 0, width, height)
end

return uistate