local state = require("misc.state")
local uistate = require("ui.uistate")
local ldebug = require("misc.debug")

local game = {}

local menu, ingame, ingamemenu

menu = {
	enter = function(self) self.id = ldebug.static("gamestate 'menu' is active.") end,
	exit = function(self) ldebug.remove(self.id) end,
	draw = function()
		local width, height = 400, 200
		love.graphics.setColor(255, 128, 0)
		love.graphics.rectangle("fill", (love.graphics.getWidth() - width) / 2, (love.graphics.getHeight() - height) / 2, width, height)
	end,
	touchreleased = function(self, id, x, y, dx, dy, pressure)
		state.push(ingame)
	end
}
ingame = {
	enter = function(self) self.id = ldebug.static("gamestate 'ingame' is active.") end,
	exit = function(self) ldebug.remove(self.id) end,
	draw = function() 
		local width, height = 100, 100
		love.graphics.setColor(0, 128, 255)
		love.graphics.rectangle("fill", 0, 0, width, height)
	end,
	touchreleased = function(self, id, x, y, dx, dy, pressure)
		state.push(ingamemenu)
	end
}
--ingamemenu = {
--	enter = function(self) self.id = ldebug.static("gamestate 'ingamemenu' is active.") end,
--	exit = function(self) ldebug.remove(self.id) end,
--	draw = function() 
--		local width, height = 400, 200
--		love.graphics.setColor(255, 128, 0)
--		love.graphics.rectangle("fill", (love.graphics.getWidth() - width) / 2, (love.graphics.getHeight() - height) / 2, width, height)
--	end,
--	touchreleased = function(self, id, x, y, dx, dy, pressure)
--		state.pop()
--	end
--}
ingamemenu = uistate(require("demo.ui.menu"))

function game.load()
	state.push(menu)
end

return game