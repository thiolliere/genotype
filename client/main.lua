-- librairies
require "lib.stateManager"
require "lib.lovelyMoon"
lovebird = require "lib.lovebird"
HC = require "HardonCollider"

require "enet"
require "entity"
require "action"
require "predict"

-- state
require "state.gameState"
require "state.menuState"

function love.run()
 
	if love.math then
		love.math.setRandomSeed(os.time())
		for i=1,3 do love.math.random() end
	end
 
	if love.event then
		love.event.pump()
	end
 
	if love.load then love.load(arg) end
 
	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end
 
	local dt = 0
 
	-- Main loop time.
	while true do
		-- the time the frame begin
		local frameBeginTime = love.timer.getTime()

		action.newIndex()

		-- Process events.
		if love.event then
			love.event.pump()
			for e,a,b,c,d in love.event.poll() do
				if e == "quit" then
					if not love.quit or not love.quit() then
						if love.audio then
							love.audio.stop()
						end
						return
					end
				end
				love.handlers[e](a,b,c,d)
			end
		end

		-- send action
		action.send()

		-- update information from snapshot if any
		do 
			local event = host:service()
			while event do
				if event.type == "receive" then
					local delta, id = false, false
					local data = event.data
					print("client receive : "..data)
					while data ~= "" do
						local type, info, rest = data:match("^([^,]*),([^;]*);(.*)$")
						data = rest

						if type == "d" then
							delta = tonumber(info)
							action.last.delta = delta
							predict.last.delta = delta
						elseif type == "i" then
							index = tonumber(info)
							action.last.index = index 
							predict.last.index = index
						elseif type == "e" then
							local pattern = "^([^,]*),([^,]*),([^,]*),([^,]*),([^,]*)$"
							local index,x,y,velocity,angle = info:match(pattern)
							index = tonumber(index)
							x = tonumber(x)
							y = tonumber(y)
							velocity = tonumber(velocity)
							angle = tonumber(angle)

							if not predict.isPredicted(index) then
								entity.solveDelta(index,x,y,velocity,angle)
							else
								predict.last = {
									index = index, 
									x = x, 
									y = y, 
									velocity = velocity, 
									angle = angle}
							end
						end
					end
					assert(delta, id)
					-- delete action already taken by last snapshot
					action.cut()
					-- delete state stored already taken by last snapshot
					predict.cut()
					if predict.diff() then
						predict.reconciliate()
					end

				elseif event.type == "connect" then
				elseif event.type == "disconnect" then
				end
				event = host:service()
			end
		end

		-- update prediction
		predict.predict()
		
		if love.window and love.graphics and love.window.isCreated() then
			love.graphics.clear()
			love.graphics.origin()
			if love.draw then love.draw() end
			love.graphics.present()
		end
 
		-- static rate
		love.timer.sleep(rate/1000 - (love.timer.getTime() - frameBeginTime))
	end
 
end
function love.load()
	addState(gameState, "game")
	addState(menuState, "menu")

	love.keyboard.setKeyRepeat(false)
	collider = HC(100, onCollision, collisionStop)

	host = enet.host_create()
	server = host:connect("localhost:6789")
	assert(host:service(10000).data == 0)
	event = host:service(10000)
	print("client first receive: "..event.data)
	assert(event.type == "receive")
	local index, entityInfo = event.data:match("^([^;]*);(.*)$")
	predict.index = tonumber(index)
	entity.initEntity(entityInfo)

	rate = 15
end

function love.update()
	lovebird.update()
	lovelyMoon.update()
end

function love.draw()
	lovelyMoon.draw()

	for _,ent in ipairs(entity) do
		if ent then
			love.graphics.setColor(255,21,45)
			ent:draw("fill")
		end
	end
end

function love.keypressed(key, isrepeat)
	if key == "escape" then
		love.event.quit()
	elseif key == "up" then
		action.newAction("sa,"..tostring(-math.pi/2)..";sv,100;")
	elseif key == "down" then
		action.newAction("sa,"..tostring(math.pi/2)..";sv,100;")
	elseif key == "right" then
		action.newAction("sa,"..tostring(0)..";sv,100;")
	elseif key == "left" then
		action.newAction("sa,"..math.pi..";sv,100;")
	end

	lovelyMoon.keypressed(key, isrepeat)
end

function love.keyreleased(key, isrepeat)
	if key == "up" then
		action.newAction("sv,0;")
	elseif key == "down" then
		action.newAction("sv,0;")
	elseif key == "right" then
		action.newAction("sv,0;")
	elseif key == "left" then
		action.newAction("sv,0;")
	end

	lovelyMoon.keyreleased(key, isrepeat)
end

function love.joystickpressed(joystick, button)
	lovelyMoon.joystickpressed(joystick, button)
end

function love.joystickreleased(joystick, button)
	lovelyMoon.joystickreleased(joystick, button)
end

function love.mousepressed(x, y, button)
	lovelyMoon.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
	lovelyMoon.mousereleased(x, y, button)
end


