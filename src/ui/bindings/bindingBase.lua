local class = require("misc.class")

local bindingBase = class("bindingBase")

function bindingBase.new()
	return {
		path = "."
	}
end

function bindingBase:provide(target)
	for pathSpec in self.path:gmatch("[^%.]+") do
		target = target[pathSpec]
		if target == nil then 
			return self.fallback
		end
	end
	
	return target
end

return bindingBase