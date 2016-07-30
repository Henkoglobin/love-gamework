local control = require("ui.control")
local class = require("misc.class")

local stackPanel = class("stackPanel", control)

function stackPanel.new()
	return {
		orientation = "vertical"
	}
end

local getLength, getOther, makeSize
function stackPanel:onMeasure(availableWidth, availableHeight)
	local usedLength, maxOther = 0, 0
	
	for i, child in ipairs(self.children) do
		local childWidth, childHeight = makeSize(self, 
			getLength(self, availableWidth, availableHeight) - usedLength,
			getOther(self, availableWidth, availableHeight)
		)
		
		child:setParent(self)
		child:measure(childWidth, childHeight)
		usedLength = usedLength + getLength(self, child.desiredWidth, child.desiredHeight)
		maxOther = math.max(maxOther, getOther(self, child.desiredWidth, child.desiredHeight))
	end
	
	return makeSize(self, usedLength, maxOther)
end

function stackPanel:onArrange(x, y, width, height)
	local usedLength = 0
	
	for i, child in ipairs(self.children) do
		local childX, childY = makeSize(self,
			getLength(self, x, y) + usedLength,
			getOther(self, x, y)
		)
		local childLength = getLength(self, child.desiredWidth, child.desiredHeight)
		local childWidth, childHeight = makeSize(self,
			childLength,
			getLength(self, width, height)
		)
		
		child:arrange(childX, childY, childWidth, childHeight)
		usedLength = usedLength + childLength
	end
	
	return x, y, makeSize(self, usedLength, getOther(self, width, height))
end

getLength = function(self, width, height)
	return self.orientation == "horizontal"
		and width
		or  height
end

getOther = function(self, width, height)
	return self.orientation == "horizontal"
		and height
		or  width
end

makeSize = function(self, length, other)
	if self.orientation == "horizontal" then
		return length, other
	else
		return other, length
	end
end

function stackPanel:onRender()
	for k, child in pairs(self.children) do
		child:render()
	end
end

function stackPanel:onTouch(id, x, y, dx, dy, pressure)
	for k, child in pairs(self.children) do
		if child:touch(id, x, y, dx, dy, pressure) then
			return
		end
	end
end

return stackPanel
