require "user"
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

		if love.window and love.graphics and love.window.isCreated() then
			love.graphics.clear()
			love.graphics.origin()
			if love.draw then love.draw() end
			love.graphics.present()
		end

		-- static rate
		do 
			local time = core.getRate()/1000 - (love.timer.getTime() - frameBeginTime)
			if time < 0 then
				return
--				if time < -rate/1000 then 
--					print("client 2 rate exceeded"..time)
--					exceeded = exceeded + 1
--				end
--
--				print("client rate exceeded"..time)
--				exceeded = exceeded + 1
--
--				love.timer.sleep(time % (rate/1000) + math.floor(time/rate*1000))
			else
--				nonexceeded = nonexceeded + 1
				love.timer.sleep(time)
			end
		end


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

				core.snapshot.newSnap(event.data)
				local old,new = core.snapshot.getSnap()

				core.action.cutToIndex(new:getLastAction())

				local index = core.prediction.getIndex()
				core.prediction.setAuthority(new:removeIndex(index))
				core.interpolation.interpolate(old,new)
				core.interpolation.initCursor()

				core.prediction.cut(#core.prediction - #core.action)
				if core.prediction.diff() then
					core.prediction.reconciliate(new)
				else
					core.prediction.predict(core.action[#core.action].code)
				end

				for i,v in pairs(core.interpolation[core.interpolation.cursor]) do
					world.solveDelta(i,v)
				end

				world.solveDelta(
					core.prediction.getIndex(),
					core.prediction[#core.prediction])


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
		core.prediction.predict(core.action[#core.action].code)

		for i,v in pairs(core.interpolation[core.interpolation.cursor]) do
			world.solveDelta(i,v)
		end

		world.solveDelta(
			core.prediction.getIndex(),
			core.prediction[#core.prediction])
	end
end

function love.draw()
	for _,obj in pairs(world.object) do
		local x,y = obj:getPosition()
		love.graphics.circle("fill",x,y,10)
	end
--	love.graphics.print("exces ratio : "..exceeded/(exceeded+nonexceeded).."\nexces : "..exceeded.."\ndiff ratio : "..diff/(diff + nondiff).."\ndiff : "..diff.."\nping : "..server:round_trip_time().."\nlastping : "..server:last_round_trip_time())
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
