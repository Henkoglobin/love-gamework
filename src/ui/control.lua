local class = require("misc.class")
local control = class()

function control.new()
	return {
		minWidth = 0,
		minHeight = 0,
		__type = "control"
	}
end

function control:measure(availableWidth, availableHeight)
	local width, height = 0, 0
	local measured = false

	if self.onMeasure then
		print(("%s.onMeasure(%d, %d)"):format(self.__type, availableWidth, availableHeight))
		self.desiredWidth, self.desiredHeight = self:onMeasure(availableHeight, availableWidth)
		print(("%s => (%d, %d)"):format(self.__type, self.desiredWidth, self.desiredHeight))
		measured = true
	end

	if self.content and not measured then
		print(("%s.onMeasure(%d, %d)"):format(self.__type, availableWidth, availableHeight))
		self.desiredWidth, self.desiredHeight = self.content:measure(availableWidth, availableHeight)
		print(("%s => (%d, %d)"):format(self.__type, self.desiredWidth, self.desiredHeight))
		measured = true
	end
	
	if not measured then
		self.desiredWidth, self.desiredHeight = 0, 0
	end

	self.desiredWidth = self.horizontalAlignment == "stretch"
		and availableWidth 
		or math.min(availableWidth, math.max(self.minWidth, self.desiredWidth))
	self.desiredHeight = self.verticalAlignment == "stretch"
		and availableHeight
		or math.min(availableHeight, math.max(self.minHeight, self.desiredHeight))

	print(("%s final => (%d, %d)"):format(self.__type, self.desiredWidth, self.desiredHeight))

	return self.desiredWidth, self.desiredHeight
end

local getActualDimensionAndOffset
function control:arrange(x, y, width, height)
	if self.onArrange then
		self.layoutRect = self:onArrange(x, y, width, height)
	end

	local actualWidth, offsetX = getActualDimensionAndOffset(self.horizontalAlignment, self.desiredWidth, width)
	local actualHeight, offsetY = getActualDimensionAndOffset(self.verticalAlignment, self.desiredHeight, height)

	self.layoutRect = { x = offsetX, y = offsetY, w = actualWidth, h = actualHeight }
	if self.content then
		self.content:arrange(x, y, width, height)
	end
end

getActualDimensionAndOffset = function(alignment, desired, available)
	if alignment == "stretch" then
		return available, 0
	elseif alignment == "start" then
		return desired, 0
	elseif alignment == "center" then
		return desired, math.floor((available - desired) / 2)
	elseif alignment == "end" then
		return desired, available - desired
	end
end

function control:render()
	local rect = self.layoutRect
	if self.onRender then
		self:onRender(rect.x, rect.y, rect.w, rect.h)
	end
	
	if self.content then
		self.content:render(rect.x, rect.y, rect.w, rect.h)
	end
end

return control