local class = require("misc.class")
local control = require("ui.control")

local label = class("label", control)

function label.new()
	return {
		foregroundColor = { 255, 255, 255, 255 },	-- rgba
		text = "<empty>",
		fontSize = 20,
		__fontSize = 20,
		font = love and love.graphics.newFont(20)
	}
end

function label:onMeasure(availableWidth, availableHeight)
	if self.fontSize ~= self.__fontSize then
		self.font = love and love.graphics.newFont(self.fontSize)
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