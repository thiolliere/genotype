require "enet"
require "entity"
HC = require "HardonCollider"

function love.load()
	host = enet.host_create("localhost:6789")

	collider = HC(100, onCollision, collisionStop)

	rate = 20

	lastAction = {}

	local iterator = 0
	doSnapshot = function()
		iterator = iterator - 1
		if iterator <= 0 then
			iterator = 4
			return true
		else
			return false
		end
	end

end

function love.run()

	if love.math then
		love.math.setRandomSeed(os.time())
		for i=1,3 do love.math.random() end
	end

	if love.load then love.load(arg) end

	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end

	local dt = 0
	local quit = false

	-- Main loop time.
	while not quit do
		-- the time the frame begin
		local frameBeginTime = love.timer.getTime()

		-- receive actions
		do 
			for _,act in ipairs(lastAction) do
				act.delta = act.delta + 1
			end

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
						lastAction[event.peer:index()] = {id = id, delta = 0}
						while data ~= "" do
							local func, values, rest= data:match("^([^,]*),([^;]*);(.*)$")
							data = rest
							if func == "sa" then
								entity[event.peer:index()]:setAngle(tonumber(values))
							elseif func == "ma" then
								entity[event.peer:index()]:moveAngle(tonumber(values))
							elseif func == "sv" then
								entity[event.peer:index()]:setVelocity(tonumber(values))
							end
						end
					end

				elseif event.type == "connect" then

					local index = event.peer:index()
					print("server : peer number "..index.." connected")
					entity.newEntity(event.peer)
					lastAction[index] = {id = 0, delta = 0}
					event.peer:send(index..";"..entity.getInformation())

				elseif event.type == "disconnect" then

					local index = event.peer:index()
					print(index.." disconnected")
					entity[index]:destroy()
					lastAction[index] = nil

				end

				event = host:service()

			end
		end

		entity.update(rate/1000)
		collider:update(rate/1000)

		-- send snapshot
		do
			if doSnapshot() then
				local entityInfo = entity.getInformation()
				local p = host:peer_count()
				for i = 1, p do
					local peer = host:get_peer(i)
					if peer:state() == "connected" then
						delta = lastAction[i].delta
						id = lastAction[i].id
						local snapshot = ""..
						"d,"..delta..";"..
						"i,"..id..";"..
						entityInfo

						peer:send(snapshot)
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
