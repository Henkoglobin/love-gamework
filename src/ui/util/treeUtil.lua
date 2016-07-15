local object = require("misc.object")
local control

local treeUtil = {}

treeUtil.visualTreePredicate = function(element)
	return object.isInstanceOf(element, control)
end

function treeUtil.traverseChildren(element, predicate, callback)
	if not control then
		control = require("ui.control")
	end
	
	if element and predicate and not callback then
		callback = predicate
		predicate = function() return true end
	end
	
	for property, value in pairs(element) do
		if type(property) ~= "string" or not property:match("^__") then
			if predicate(value) then
				callback(value)
			end
			
			if type(value) == "table" and property ~= "parent" then
				treeUtil.traverseChildren(value, predicate, callback)
			end
		end
	end
end

return treeUtil