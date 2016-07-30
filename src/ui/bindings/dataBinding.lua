local class = require("misc.class")
local bindingBase = require("ui.bindings.bindingBase")

local dataBinding = class("dataBinding", bindingBase)

function dataBinding.new()
	return {
		path = "."
	}
end

function dataBinding:provide(target)
	for pathSpec in self.path:gmatch("[^%.]+") do
		target = target[pathSpec]
		if target == nil then
			return self.fallback
		end
	end

	return target
end

return dataBinding