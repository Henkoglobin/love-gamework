local ldebug = require("misc.debug")
local game = require("game")
local state = require("misc.state")

function love.draw()
	local currstate = state.get()
	if currstate.draw then
		currstate:draw()
	end
	
	if ldebug.isEnabled() then
		love.graphics.setColor(255, 255, 255)
		love.graphics.print(ldebug.get(), 20, 20)
	end
end

function love.update(dt)
	local currstate = state.get()
	if currstate.update then
		currstate:update(dt)
	end
end

function love.touchreleased(id, x, y, dx, dy, pressure)
	local currstate = state.get()
	if currstate.touchreleased then
		currstate:touchreleased(id, x, y, dx, dy, pressure)
	end
end

function love.load()
	local font = love.graphics.newFont(40)
	love.graphics.setFont(font)
	
	ldebug.append(function() return ("This game has been running for %.3fs"):format(os.clock()) end)
	ldebug.append(function() return ("Game Window size is %dx%d"):format(love.graphics.getWidth(), love.graphics.getHeight()) end)
	ldebug.append(("Operating System: %s"):format(love.system.getOS()))
	
	game.load()
end