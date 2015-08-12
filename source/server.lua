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
		print("server : loaded")
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
					print("server receive : "..data)
					local packetType, rest = data:match("^(%a)(.*)$")
					data = rest
					if packetType == "a" then
						local id, rest= data:match("^([^;]*);(.*)$")
						data = rest
						lastAction[event.peer:index()] = id
						while data ~= "" do
							local func, values, rest= data:match("^([^,]*),([^;]*);(.*)$")
							data = rest
							if func == "sa" then
								world.object[event.peer:index()]:setAngle(tonumber(values))
							elseif func == "ma" then
								world.object[event.peer:index()]:moveAngle(tonumber(values))
							elseif func == "sv" then
								world.object[event.peer:index()]:setVelocity(tonumber(values))
							end
						end
					end

				elseif event.type == "connect" then

					local index = event.peer:index()
					print("server : peer number "..index.." connected")
					world.object[index] = world.hoverfly.create()
					lastAction[index] = 0
					event.peer:send(index..";"..
		     				rate..";"..
						deltaBetweenSnapshot..";"..
						lastAction[index]..";"..
						world.encodeObject())

				elseif event.type == "disconnect" then

					local index = event.peer:index()
					print("server : "..index.." disconnected")
					world[index]:destroy()
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

	end

	if not love.quit or not love.quit() then
		return
	end
end
