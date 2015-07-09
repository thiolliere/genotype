-- librairies
require "lib.stateManager"
require "lib.lovelyMoon"
lovebird = require "lib.lovebird"

require "enet"

-- state
require "state.gameState"
require "state.menuState"

function love.load()
	addState(gameState, "game")
	addState(menuState, "menu")

	host = enet.host_create()
	server = host:connect("localhost:6789")
end

function love.update()
	print("client update")
	lovebird.update()
	lovelyMoon.update()

	local event = host:service()
	while event do
		if event.type == "receive" then
			print("client got message : ", event.data)
		elseif event.type == "connect" then
		elseif event.type == "disconnect" then
		end
		event = host:service()
	end
end

function love.draw()
	lovelyMoon.draw()
end

function love.keypressed(key, isrepeat)
	if key == "escape" then
		love.event.quit()
	elseif key == "up" then
	elseif key == "down" then
	elseif key == "right" then
		server:send("a,sa,"..tostring(0)..";a,sv,1;")
	elseif key == "left" then
		server:send("a,sa,"..math.pi..";a,sv,1;")
	end

	lovelyMoon.keypressed(key, isrepeat)
end

function love.keyreleased(key, isrepeat)
	if key == "up" then
	elseif key == "down" then
	elseif key == "right" then
		server:send("a,sv,0;")
	elseif key == "left" then
		server:send("a,sv,0;")
	end

	lovelyMoon.keyreleased(key, isrepeat)
end

function love.joystickpressed(joystick,button)
	lovelyMoon.joystickpressed(joystick, button)
end

function love.joystickreleased(joystick,button)
	lovelyMoon.joystickreleased(joystick, button)
end

function love.mousepressed(x, y, button)
	lovelyMoon.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
	lovelyMoon.mousereleased(x, y, button)
end


