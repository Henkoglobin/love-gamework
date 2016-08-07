local class = require("misc.class")
local bindingBase = require("ui.bindings.bindingBase")

local dataBinding = class("dataBinding", bindingBase)

function dataBinding.new()
	return {}
end

return dataBinding