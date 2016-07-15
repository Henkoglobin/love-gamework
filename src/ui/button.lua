local control = require("ui.control")
local class = require("misc.class")

local button = class("button", control)

function button.new()
	return {
		style = require("ui.styles.button")
	}
end

local canExecuteChangedCallback
class.property(button, "command", {
	get = function(self)
		return self.__command
	end,
	set = function(self, value)
		if self.__command then
			self.__command:unregister(canExecuteChangedCallback, self)
		end
		self.__command = value
		self.__command:register(canExecuteChangedCallback, self)
		canExecuteChangedCallback(self)
	end
})

canExecuteChangedCallback = function(self)
	if self.command:canExecute(self.commandParameter) then
		self.style = require("ui.styles.button")
	else
		self.style = require("ui.styles.button_disabled")
	end
	self.content = nil
	self:invalidate()
end

function button:onTouch(id, x, y, dx, dy, pressure)
	if self.command and self.command:canExecute(self.commandParameter) then
		self.command:execute(self.commandParameter)
	end
end

return button
