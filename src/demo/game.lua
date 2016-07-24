local state = require("misc.state")
local uistate = require("ui.uistate")
local ldebug = require("misc.debug")

local game = {}
local menu = uistate(require("demo.ui.menu"))

function game.load()
	state.push(menu)
end

return game