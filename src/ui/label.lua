local class = require("misc.class")
local control = require("ui.control")

local label = class(control)

function label.new()
	return {
		foregroundColor = { 255, 255, 255, 255 },	-- rgba
		text = "",
		fontSize = 20,
		__fontSize = 20,
		font = love.graphics.newFont(20),
		__type = "label"
	}
end

function label:onMeasure(availableWidth, availableHeight)
	if self.fontSize ~= self.__fontSize then
		self.font = love.graphics.newFont(self.fontSize)
		self.__fontSize = self.fontSize
	end
	
	local w, h = self.font:getWidth(self.text), self.font:getHeight()
	
	-- TODO: Logic to split string if it's too long to display within the bounds
	
	return w, h
end

function label:onRender(x, y, width, height)
	love.graphics.push("all")
	love.graphics.setFont(self.font)
	love.graphics.setColor(self.foregroundColor)
	love.graphics.print(self.text, x, y)
	love.graphics.pop()
end

return label