local ldebug = require("misc.debug")
local game = require("game")
local state = require("misc.state")
local config = require("config")

local debugFont

local love = love or {}
function love.draw()
	local currstate = state.get()
	if currstate.draw then
		currstate:draw()
	end

	if ldebug.isEnabled() then
		love.graphics.push("all")
		love.graphics.setFont(debugFont)
		love.graphics.setColor(255, 255, 255)
		love.graphics.print(ldebug.get(), 20, 20)
		love.graphics.pop()
	end
end

function love.update(dt)
	local currstate = state.get()
	if currstate.update then
		currstate:update(dt)
	end
end

function love.touchreleased(id, x, y, dx, dy, pressure)
	if not config.useTouch then
		return
	end
	
	local currstate = state.get()
	if currstate.touchreleased then
		currstate:touchreleased(id, x, y, dx, dy, pressure)
	end
end

function love.mousereleased(x, y, button, istouch)
	if not config.useMouse then
		return
	end

	local currstate = state.get()
	if currstate.touchreleased then
		currstate:touchreleased(nil, x, y, nil, nil, nil)
	end
end

function love.load()
	debugFont = love.graphics.newFont(10)

	ldebug.static(function() return ("This game has been running for %.3fs"):format(os.clock()) end)
	ldebug.static(function() return ("Game Window size is %dx%d"):format(love.graphics.getWidth(), love.graphics.getHeight()) end)
	ldebug.static(("Operating System: %s"):format(love.system.getOS()))

	game.load()
end