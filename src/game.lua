-- Forward to playground/game.lua
local config = require("config")

config.useTouch = false
config.useMouse = true

return require("demo.game")

