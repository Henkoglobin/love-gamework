local class = require("misc.class")
local control = class()

function control.new()
	return {
		minWidth = 0,
		minHeight = 0,
		padding = { 0, 0, 0, 0 },
		margin = { 0, 0, 0, 0 },
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

	self.desiredWidth = self.desiredWidth + self.padding[1] + self.padding[3]
	self.desiredHeight = self.desiredHeight + self.padding[2] + self.padding[4]

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
		return
	end

	local actualWidth, offsetX = getActualDimensionAndOffset(self.horizontalAlignment, self.desiredWidth, width)
	local actualHeight, offsetY = getActualDimensionAndOffset(self.verticalAlignment, self.desiredHeight, height)

	print(("%s without padding {%d, %d, %d, %d}"):format(self.__type, offsetX, offsetY, actualWidth, actualHeight))

	local rect = {
		x = x + offsetX + self.padding[1], 
		y = y + offsetY + self.padding[2], 
		w = actualWidth - self.padding[1] - self.padding[3], 
		h = actualHeight - self.padding[2] - self.padding[4]
	}

	print(("%s is layed out { %d, %d, %d, %d }"):format(self.__type, rect.x, rect.y, rect.w, rect.h))

	if self.content then
		self.content:arrange(rect.x, rect.y, rect.w, rect.h)
	end

	self.layoutRect = rect
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