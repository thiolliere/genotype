gameState = {}

--New
function gameState:new()
	local gs = {}

	gs = setmetatable(gs, self)
	self.__index = self
	_gs = gs

	return gs
end

--Load
function gameState:load()
end

--Close
function gameState:close()
end

--Enable
function gameState:enable()
end

--Disable
function gameState:disable()
end

--Update
function gameState:update(dt)
end

--Draw
function gameState:draw()
end

--KeyPressed
function gameState:keypressed(key, unicode)
end

--KeyReleased
function gameState:keyreleased(key, unicode)
end

--JoystickPressed
function gameState:joystickpressed(joystick, button)
end

--JoystickReleased
function gameState:joystickreleased(joystick, button)
end

--MousePressed
function gameState:mousepressed(x, y, button)
end

--MouseReleased
function gameState:mousereleased(x, y, button)
end
