local class = require("misc.class")
local parser = require("ui.parser")
local treeUtil = require("ui.util.treeUtil")
local rectUtil = require("ui.util.rectUtil")
local templateBinding = require("ui.bindings.templateBinding")
local dataBinding = require("ui.bindings.dataBinding")

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

class.property(control, "dataContext", {
	get = function(self)
		print(("Getting dataContext... parent is set: %s"):format(self.parent ~= nil))
		return self.parent and self.parent.dataContext
	end
})

class.property(control, "dataContextStack", {
	get = function(self)
		return setmetatable({}, {
			__index = function(self, index)
				if type(index) ~= "number" then
					return nil
				end

				local obj = self
				while obj and index > 0 do
					if obj.__dataContext then
						index = index - 1
						if index == 0 then
							return obj.__dataContext
						end
						obj = obj.parent
					end
				end
			end
		})
	end
})

local updateBindings
function control:setDataContext(context)
	self.dataContext = context
	updateBindings(self)
end

function control:addBinding(property, binding)
	print(("Added binding on %s"):format(property))
	self.__bindings[property] = binding
	updateBindings(self)
end

function control:setTemplateBindingTarget(targetControl)
	self.__templateBindingTarget = targetControl
	updateBindings(self)
end

updateBindings = function(self)
	for prop, binding in pairs(self.__bindings or {}) do
		if binding:instanceOf(templateBinding) then
			if self.__templateBindingTarget then
				self[prop] = binding:provide(self.__templateBindingTarget)
			end
		elseif binding:instanceOf(dataBinding) then
			local dataContext = self.dataContext
			if dataContext then
				self[prop] = binding:provide(dataContext)
			else
				print("... but dataContext was nil")
			end
		end
	end
end

function control:setParent(parent)
	self.parent = parent
	updateBindings(self)
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
		self.desiredWidth, self.desiredHeight = self:onMeasure(availableWidth, availableHeight)
		measured = true
	end

	if self.content and not measured then
		self.content:setParent(self)
		self.desiredWidth, self.desiredHeight = self.content:measure(availableWidth, availableHeight)
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

	if self.onArrange then
		local rect = { self:onArrange(rect.x, rect.y, rect.w, rect.h) }
		if #rect ~= 4 then
			error(("%s:onArrange() returned an invalid amount of values. Expected: 4, actual: %d"):format(self.__type, #rect))
		end

		self.layoutRect = {
			x = rect[1],
			y = rect[2],
			w = rect[3],
			h = rect[4]
		}

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
		error(("Invalid alignment '%s', expected: 'start', 'center', 'end' or 'stretch'"):format(alignment), 3)
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

function control:touch(id, x, y, dx, dy, pressure)
	local rect = self.layoutRect

	if not rectUtil.isInRect(self.layoutRect, x, y) then
		return false
	end

	if self.onTouch then
		return self:onTouch(id, x, y, dx, dy, pressure)
	end

	if self.content then
		return self.content:touch(id, x, y, dx, dy, pressure)
	end

	return false
end

function control:invalidate()
	if self.parent then
		self.parent:invalidate()
	end
end

return control
