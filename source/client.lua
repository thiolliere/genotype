function love.load()
	love.keyboard.setKeyRepeat(false)

	host = enet.host_create()
	server = host:connect("localhost:6789")

	assert(host:service(10000).data == 0)

	event = host:service(10000)
	print("client first receive: "..event.data)
	assert(event.type == "receive")


	local index, rate, delta, snap = event.data:match("^([^;]*);([^;]*);([^;]*);(.*)$")

	index = tonumber(index)
	delta = tonumber(delta)
	core.setRate(rate)
	core.snapshot.setDelta(delta)
	core.prediction.setIndex(index)

	core.snapshot.newSnap(snap)
	local old, new = core.snapshot.getSnap()

	local auth = new:removeIndex(index)
	core.prediction.setAuthority(auth)
	core.interpolation.interpolate(old, new)
	core.interpolation.initCursor()

	core.prediction.reconciliate(core.snapshot.new)

	for i,v in pairs(new:getObject()) do
		world.solveDelta(i,v)
	end
	world.solveDelta(core.prediction.getIndex(),core.prediction.getPrediction())

	if user and user.load then 
		user.load()
	end

	--	rate = 20
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

		core.action.newIndex()

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

		if user and user.update then
			user.update()
		end

		-- send action
		core.action.send()

		-- update world
		love.update()

		if love.gotTime() and love.window and love.graphics and love.window.isCreated() then
			love.graphics.clear()
			love.graphics.origin()
			if love.draw then love.draw() end
			love.graphics.present()
		end

		love.sleep()

		if love.timer then
			love.timer.step()
			dt = love.timer.getDelta()
		end
	end
end


function love.update()
	-- update information from snapshot if any
	local event = host:service()
	if event then
		while event do
			if event.type == "receive" then
				print("client receive : "..event.data)

				local dsnap = core.snapshot.decode(event.data)

				local n = core.action.cutToIndex(snap:getLastAction())

				core.snapshot.completeSnap(dsnap,core.snapshot.getLast())
				local snap = dsnap

				core.prediction.setAuthority(
					core.snapshot.removeIndex(index, snap))
				core.interpolation.interpolate(core.snapshot.last,snap)
				core.interpolation.initCurrent()

				core.prediction.cut(#core.prediction - #core.action)
				if core.diff(
					core.prediction[1], 
					core.prediction.getAuthority) then

					core.prediction.reconciliate(snap)
				else
					core.prediction.predict(core.action[#core.action])
				end

				for i,v in pairs(core.snapshot.getObject(snap)) do
					world.solveDelta(i,v)
				end
				world.solveDelta(core.prediction.getIndex(),core.prediction[#core.prediction])

			elseif event.type == "connect" then
			elseif event.type == "disconnect" then
			end
			event = host:service()
			if event then
				print("-- two snapshot in a frame")
				return
			end
		end
	else
		core.interpolation.incCursor()
		core.prediction.predict()

		for i,v in pairs(core.snapshot.getObject(snap)) do
			world.solveDelta(i,v)
		end

		world.solveDelta(
			core.prediction.getIndex(),
			core.prediction[#core.prediction])
	end
end

function love.draw()
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
			local a = math.random(1,314*2)/100
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
end
