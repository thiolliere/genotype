-- librairies
require "lib.stateManager"
require "lib.lovelyMoon"
HC = require "HardonCollider"

require "enet"
require "entity"
require "action"
require "predict"

require "deb"
-- state
require "state.gameState"
require "state.menuState"

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

	exceeded = 0
	nonexceeded = 0
	diff = 0
	nondiff = 0

	rate = 20
end

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
		print("\n----\n")
		-- the time the frame begin
		local frameBeginTime = love.timer.getTime()

		action.newIndex()

		deb.b("process event")
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
		deb.e("process event")

		userAction()

		deb.b("send action")
		-- send action
		action.send()
		deb.e("send action")

		-- update information from snapshot if any
		deb.b("receive snapshot")
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
								predict.authority = {
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
					-- remove all prediction of the state before this snapshot
					predict.cut()
					if predict.diff() then
						print("-- prediction diff --")
						diff = diff + 1
						predict.reconciliate()

--						if true then
--							print("getdeltasnapframe = ",action.getDeltaSnapFrame())
--							print("action : ")
--							print("action delta=",action.last.delta," index=",action.last.index) 
--							for i,v in ipairs(action) do
--								print("action["..i.."]= index="..v.index.." code="..v.code)
--							end
--							print("prediction : ")
--							if predict.authority then
--								print("auth: x="..predict.authority.x.." y="..predict.authority.y.." predict.authority="..predict.authority.velocity.." a="..predict.authority.angle)
--							end
--							for i,v in ipairs(predict) do
--								print("predict["..i.."]= x="..v.x.." y="..v.y.." v="..v.velocity.." a="..v.angle)
--							end
--							return
--						end
					else
						nondiff = nondiff + 1
					end

				elseif event.type == "connect" then
				elseif event.type == "disconnect" then
				end
				event = host:service()
			end
		end
		deb.e("receive snapshot")

		deb.b("predict")
		-- update prediction
		if action.getDeltaSnapFrame() > 0 then
			predict.predict(action[#action].code)
		end
		deb.e("predict")
		
		deb.b("draw")
		deb.b("condition")
		if love.window and love.graphics and love.window.isCreated() then
			deb.e("condition")
			deb.b("clear")
			love.graphics.clear()
			deb.e("clear")
			deb.b("origin")
			love.graphics.origin()
			deb.e("origin")
			deb.b("love draw")
			if love.draw then love.draw() end
			deb.e("love draw")
			deb.b("present")
			love.graphics.present()
			deb.e("present")
		end
		deb.e("draw")
 
		deb.b("sleep")
		-- static rate
		do 
			local time = rate/1000 - (love.timer.getTime() - frameBeginTime)
			if time < 0 then
				if time < -rate/1000 then 
					print("client 2 rate exceeded"..time)
					exceeded = exceeded + 1
				end

				print("client rate exceeded"..time)
				exceeded = exceeded + 1

				love.timer.sleep(time % (rate/1000) + math.floor(time/rate*1000))
				return
			else
				nonexceeded = nonexceeded + 1
				love.timer.sleep(time)
			end
		end
		deb.e("sleep")
		print("getdeltasnapframe = ",action.getDeltaSnapFrame())
		print("action : ")
		print("action delta=",action.last.delta," index=",action.last.index) 
		for i,v in ipairs(action) do
			print("action["..i.."]= index="..v.index.." code="..v.code)
		end
		print("prediction : ")
		if predict.authority then
			print("auth: x="..predict.authority.x.." y="..predict.authority.y.." predict.authority="..predict.authority.velocity.." a="..predict.authority.angle)
		end
		for i,v in ipairs(predict) do
			print("predict["..i.."]= x="..v.x.." y="..v.y.." v="..v.velocity.." a="..v.angle)
		end
	end
end


function love.update()
	lovelyMoon.update()
end

function love.draw()
	lovelyMoon.draw()

	for _,ent in ipairs(entity) do
		if ent then
			local x,y = ent:getPosition()
			love.graphics.circle("fill",x,y,10)
		end
	end
	love.graphics.print("exces ratio : "..exceeded/(exceeded+nonexceeded).."\nexces : "..exceeded.."\ndiff ratio : "..diff/(diff + nondiff).."\ndiff : "..diff.."\nping : "..server:round_trip_time().."\nlastping : "..server:last_round_trip_time())
end

if arg[2] and arg[2] == "bot" then
	timeToChange = 0
	function userAction()
		local reposition = 0.3
		local v = 300
		local x = entity[predict.index]:getX()
		local y = entity[predict.index]:getY()
		local w = love.window.getWidth()
		local h = love.window.getHeight()

		if entity[predict.index].velocity == 0 then
			action.newAction("sv,"..v..";")
		end
		if entity[predict.index].x then
			print(w,entity[predict.index].x)
		end
		if x > w then
			timeToChange = love.timer.getTime() + reposition
			action.newAction("sa,"..tostring(math.pi)..";")
		elseif x < 0 then
			timeToChange = love.timer.getTime() + reposition
			action.newAction("sa,"..tostring(0)..";")
		elseif y > h then
			timeToChange = love.timer.getTime() + reposition
			action.newAction("sa,"..tostring(-math.pi/2)..";")
		elseif y < 0 then
			timeToChange = love.timer.getTime() + reposition
			action.newAction("sa,"..tostring(math.pi/2)..";")
		elseif love.timer.getTime() > timeToChange then
			local a = math.random(1,314)/100
			action.newAction("sa,"..tostring(a)..";")
			timeToChange = love.timer.getTime() + math.random(0.2,2)
		end
	end

else
	function userAction()
		local v = 300
		if love.keyboard.isDown("up") then
			if love.keyboard.isDown("right") then
				local a = -math.pi/4
				if entity[predict.index]:getAngle() ~= a then
					action.newAction("sa,"..tostring(a)..";")
				end
				if entity[predict.index]:getVelocity() ~= v then
					action.newAction("sv,"..v..";")
				end
			elseif love.keyboard.isDown("left") then
				local a = -math.pi*3/4
				if entity[predict.index]:getAngle() ~= a then
					action.newAction("sa,"..tostring(a)..";")
				end
				if entity[predict.index]:getVelocity() ~= v then
					action.newAction("sv,"..v..";")
				end
			else
				local a = -math.pi/2
				if entity[predict.index]:getAngle() ~= a then
					action.newAction("sa,"..tostring(a)..";")
				end
				if entity[predict.index]:getVelocity() ~= v then
					action.newAction("sv,"..v..";")
				end
			end
		elseif love.keyboard.isDown("down") then
			if love.keyboard.isDown("right") then
				local a = math.pi/4
				if entity[predict.index]:getAngle() ~= a then
					action.newAction("sa,"..tostring(a)..";")
				end
				if entity[predict.index]:getVelocity() ~= v then
					action.newAction("sv,"..v..";")
				end
			elseif love.keyboard.isDown("left") then
				local a = math.pi*3/4
				if entity[predict.index]:getAngle() ~= a then
					action.newAction("sa,"..tostring(a)..";")
				end
				if entity[predict.index]:getVelocity() ~= v then
					action.newAction("sv,"..v..";")
				end
			else
				local a = math.pi/2
				if entity[predict.index]:getAngle() ~= a then
					action.newAction("sa,"..tostring(a)..";")
				end
				if entity[predict.index]:getVelocity() ~= v then
					action.newAction("sv,"..v..";")
				end
			end
		elseif love.keyboard.isDown("right") then
			local a = 0
			if entity[predict.index]:getAngle() ~= a then
				action.newAction("sa,"..tostring(a)..";")
			end
			if entity[predict.index]:getVelocity() ~= v then
				action.newAction("sv,"..v..";")
			end
		elseif love.keyboard.isDown("left") then
			local a = math.pi
			if entity[predict.index]:getAngle() ~= a then
				action.newAction("sa,"..tostring(a)..";")
			end
			if entity[predict.index]:getVelocity() ~= v then
				action.newAction("sv,"..v..";")
			end
		else
			if entity[predict.index]:getVelocity() ~= 0 then
				action.newAction("sv,0;")
			end
		end
	end
end

function love.keypressed(key, isrepeat)
	if key == "escape" then
		server:disconnect()
		while server:state() ~= "disconnected" do
			print(server:state())
			love.timer.sleep(0.1)
			host:service()
		end
		love.event.quit()
	end

	lovelyMoon.keypressed(key, isrepeat)
end

function love.keyreleased(key, isrepeat)
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


