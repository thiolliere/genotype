require "enet"
require "world"

function love.run()

	if love.math then
		love.math.setRandomSeed(os.time())
		for i=1,3 do love.math.random() end
	end

	do
		host = enet.host_create("localhost:6789")

		rate = 20

		lastAction = {}

		deltaBetweenSnapshot = 4
		local iterator = 0
		timeToSendSnapshot = function()
			iterator = iterator - 1
			if iterator <= 0 then
				iterator = deltaBetweenSnapshot
				return true
			else
				return false
			end
		end
	end

	local dt = 0
	local quit = false

	-- Main loop time.
	while not quit do
		-- the time the frame begin
		local frameBeginTime = love.timer.getTime()

		-- receive actions
		do 
			local event = host:service()
			while event do
				if event.type == "receive" then

					local data = event.data
					local packetType, rest = data:match("^(%a)(.*)$")
					data = rest
					if packetType == "a" then
						local id, code = data:match("^([^;]*);(.*)$")
						lastAction[event.peer:index()] = id
						core.action.apply(event.peer:index(),code)
					end

				elseif event.type == "connect" then

					local index = event.peer:index()
					world.object[index] = world.hoverfly.create(index)
					lastAction[index] = 0
					event.peer:send(index..";"..
		     				rate..";"..
						deltaBetweenSnapshot..";"..
						lastAction[index]..";"..
						world.encodeObject())

				elseif event.type == "disconnect" then

					local index = event.peer:index()
					world.object[index]:destroy()
					lastAction[index] = nil

				end

				event = host:service()

			end
		end

		world.update(rate/1000)

		-- send snapshot
		do
			if timeToSendSnapshot() then
				local objectData = world.encodeObject()
				local p = host:peer_count()
				for i = 1, p do
					local peer = host:get_peer(i)
					if peer:state() == "connected" then
						peer:send(core.snapshot.encodeSnap(lastAction[i],objectData))
					end
				end
			end
		end

		-- static rate
		do 
			local time = rate/1000 - (love.timer.getTime() - frameBeginTime)
			if time < 0 then
				print("!! server rate exceeded !!")
			else
				love.timer.sleep(time)
			end
		end

		-- debug print
		do
			local msg = "\n----------\n\n"
			local p = host:peer_count()
			for i = 1 , p do
				local peer = host:get_peer(i)
				if peer:state() == "connected" then
					t = world.object[i]:getAttribut()
					msg=msg.."peer : index "..i..", lastActionindex "..lastAction[i].."\n".."--> type="..t.type..",x="..t.x..",y="..t.y.."\n"..
						"--> velocity="..t.velocity..",angle="..t.angle..",state="..t.state..",count="..t.count.."\n"
				end
			end
			print(msg)
			
		end

	end

	if not love.quit or not love.quit() then
		return
	end
end
