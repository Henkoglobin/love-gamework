local class = require("misc.class")
local binding = require("ui.bindings.bindingBase")

local templateBinding = class("templateBinding", binding)

function templateBinding.new()
	return {}
end

return templateBinding