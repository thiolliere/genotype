-- librairies
require "lib.stateManager"
require "lib.lovelyMoon"
require "lib.lovebird"

-- state
require "state.gameState"
require "state.menuState"

function love.load()
	addState(gameState, "game")
	addState(menuState, "menu")
end

function love.update()
	lovebird.update()
	lovelyMoon.update()
end

function love.draw()
	lovelyMoon.draw()
end

function love.keypressed(key, unicode)
	lovelyMoon.keypressed(key, unicode)
end

function love.keyreleased(key, unicode)
	lovelyMoon.keyreleased(key, unicode)
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


