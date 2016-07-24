local from = require("lib.lazylualinq.linq")
local class = require("misc.class")
local control = require("ui.control")
local serialize = require("misc.serialize")

local grid = class("grid", control)

function grid.new()
	return {
		horizontalAlignment = "stretch",
		verticalAlignment = "stretch"
	}
end

local parseLength, getMeasurePriority, getLength
function grid:onMeasure(availableWidth, availableHeight)
	local colWidths, rowHeights = {}, {}
	local widthUsed, heightUsed = 0, 0
	local starCols, starRows = {}, {}
	local totalStarsInCols, totalStarsInRows = 0, 0
	
	for colId, col in ipairs(self.columns) do
		local length = parseLength(col.width)
		if length.mode == "pixels" then
			colWidths[colId] = length.length
			widthUsed = widthUsed + colWidths[colId]
			
			from(self.children)
				:where(function(child) return child["grid.column"] == colId end)
				:foreach(function(_, child)
					child:measure(colWidths[colId], availableHeight)
				end)
		elseif length.mode == "auto" then
			colWidths[colId] = from(self.children)
				:where(function(child) return child["grid.column"] == colId end)
				:select(function(child) 
					child:measure(availableWidth - widthUsed, availableHeight)
					return child.desiredWidth
				end)
				:max()
			widthUsed = widthUsed + colWidths[colId]
		elseif length.mode == "star" then
			starCols[colId] = col
			totalStarsInCols = totalStarsInCols + length.length
		end
	end
	
	for colId, col in pairs(starCols) do
		colWidths[colId] = math.floor((availableWidth - widthUsed) / totalStarsInCols * parseLength(col.width).length)
		from(self.children)
			:where(function(child) return child["grid.column"] == colId end)
			:foreach(function(_, child)
				child:measure(colWidths[colId], availableHeight)
			end)
	end
	
	for rowId, row in ipairs(self.rows) do
		local length = parseLength(row.height)
		if length.mode == "pixels" then
			rowHeights[rowId] = length.length
			heightUsed = heightUsed + rowHeights[rowId]
			
			from(self.children)
				:where(function(child) return child["grid.row"] == rowId end)
				:foreach(function(_, child)
					child:measure(colWidths[child["grid.column"]], rowHeights[rowId])
				end)
		elseif length.mode == "auto" then
			rowHeights[rowId] = from(self.children)
				:where(function(child) return child["grid.row"] == rowId end)
				:select(function(child)
					child:measure(colWidths[child["grid.column"]], availableHeight - heightUsed)
					return child.desiredHeight
				end)
				:max()
			heightUsed = heightUsed + rowHeights[rowId]
		elseif length.mode == "star" then
			starRows[rowId] = row
			totalStarsInRows = totalStarsInRows + length.length
		end
	end
	
	for rowId, row in pairs(starRows) do
		rowHeights[rowId] = math.floor((availableHeight - heightUsed) / totalStarsInRows * parseLength(row.height).length)
		from(self.children)
			:where(function(child) return child["grid.row"] == rowId end)
			:foreach(function(_, child)
				child:measure(colWidths[child["grid.column"]], rowHeights[rowId])
			end)
	end
	
	self.colWidths, self.rowHeights = colWidths, rowHeights
	
	print(("wxh: %s x %s"):format(availableWidth, availableHeight))
	print(serialize(colWidths, "colWidths"))
	print(serialize(rowHeights, "rowHeights"))
	
	return from(self.colWidths):sum(), from(self.rowHeights):sum()
end

function grid:onArrange(x, y, width, height)
	for _, child in pairs(self.children) do
		local row, col = child["grid.row"], child["grid.column"]
		local cx = from(self.colWidths):where(function(w, i) return i < col end):sum()
		local cy = from(self.rowHeights):where(function(r, i) return i < row end):sum()
		local cw = self.colWidths[col]
		local ch = self.rowHeights[row]
		
		child:arrange(x + cx, y + cy, cw, ch)
	end
	
	return x, y, width, height
end

function grid:onRender()
	for _, child in pairs(self.children) do
		child:render()
	end
end

parseLength = function(length)
	print(("parseLength(%s)"):format(length))
	if type(length) == "string" then
		if length == "auto" then
			return { length = -1, mode = "auto" }
		else
			local weight, star = length:match("^(%d*)(%*)$")
			if star then
				return { length = tonumber(weight) or 1, mode = "star" }
			end
		end
	else
		return { length = length, mode = "pixels" }
	end
	
	error(("Could not parse length %s"):format(length))
end

getMeasurePriority = function(parsedLength)
	return ({
		pixels = 1,
		auto = 2,
		star = 5
	})[parsedLength.mode]
end

getLength = function(length, availableLength, usedLength, starBaseLength)
	if length.mode == "pixels" then
		return math.max(length.length, availableLength - usedLength)
	elseif length.mode == "auto" then
		return availableLength - usedLength
	elseif length.mode == "star" then
		return math.max(starBaseLength * length.length, availableLength - usedLength)
	end
	
	error(("Unknown length mode '%s'"):format(length.mode))
end

return grid