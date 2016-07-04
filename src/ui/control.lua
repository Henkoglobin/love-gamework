local class = require("misc.class")
local parser = require("ui.parser")
local treeUtil = require("ui.util.treeUtil")

local control = class("control")

function control.new()
	return {
		minWidth = 0,
		minHeight = 0,
		padding = { 0, 0, 0, 0 },
		margin = { 0, 0, 0, 0 },
		horizontalAlignment = "start",
		verticalAlignment = "start",
		__bindings = {}
	}
end

local updateBindings
function control:addBinding(property, binding)
	self.__bindings[property] = binding
	updateBindings(self)
end

function control:setTemplateBindingTarget(targetControl)
	print("template Binding Target set")
	self.__templateBindingTarget = targetControl
	updateBindings(self)
end

updateBindings = function(self)
	if self.__templateBindingTarget then
		for prop, binding in pairs(self.__bindings or {}) do
			self[prop] = binding:provide(self.__templateBindingTarget)
		end
	end
end

function control:measure(availableWidth, availableHeight)
	local width, height = 0, 0
	local measured = false

	if self.style and not self.content then
		self.content = parser.parse(self.style)

		treeUtil.traverseChildren(self, treeUtil.visualTreePredicate, 
			function(element)
				element:setTemplateBindingTarget(self)
			end)
	end

	availableWidth = availableWidth - self.margin[1] - self.margin[3]
	availableHeight = availableHeight - self.margin[2] - self.margin[4]

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

	self.desiredWidth = self.desiredWidth + self.padding[1] + self.padding[3] + self.margin[1] + self.margin[3]
	self.desiredHeight = self.desiredHeight + self.padding[2] + self.padding[4] + self.margin[2] + self.margin[4]

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
	local actualWidth, offsetX = getActualDimensionAndOffset(self.horizontalAlignment, self.desiredWidth, width, self.margin[1], self.margin[3])
	local actualHeight, offsetY = getActualDimensionAndOffset(self.verticalAlignment, self.desiredHeight, height, self.margin[2], self.margin[4])

	local rect = {
		x = x + offsetX,
		y = y + offsetY,
		w = actualWidth,
		h = actualHeight
	}

	print(("%s is layed out { %d, %d, %d, %d }"):format(self.__type, rect.x, rect.y, rect.w, rect.h))

	if self.onArrange then
		self.layoutRect = { self:onArrange(rect.x, rect.y, rect.w, rect.h) }
		if #self.layoutRect ~= 4 then
			error(("%s:onArrange() returned an invalid amount of values. Expected: 4, actual: %d"):format(self.__type, #self.layoutRect))
		end

		return
	end

	if self.content then
		self.content:arrange(rect.x, rect.y, rect.w, rect.h)
	end

	self.layoutRect = rect
end

getActualDimensionAndOffset = function(alignment, desired, available, marginStart, marginEnd)
	if alignment == "stretch" then
		return available - marginStart - marginEnd, marginStart
	elseif alignment == "start" then
		return desired, marginStart
	elseif alignment == "center" then
		return desired, math.floor((available - desired) / 2) + marginStart
	elseif alignment == "end" then
		return desired, available - desired - marginEnd
	else
		error(("Invalid alignment %s"):format(alignment), 3)
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