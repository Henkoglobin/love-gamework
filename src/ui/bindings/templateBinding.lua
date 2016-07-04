local class = require("misc.class")
local binding = require("ui.bindings.bindingBase")

local templateBinding = class("templateBinding", binding)

function templateBinding.new()
	return {
		path = "."
	}
end

function templateBinding:provide(target)
	print("[PROVIDE]")
	for pathSpec in self.path:gmatch("[^%.]+") do
		print("[PROVIDE] " .. pathSpec)
		target = target[pathSpec]
		if target == nil then 
			return self.fallback
		end
	end
	
	return target
end

return templateBinding