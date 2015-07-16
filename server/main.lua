require "enet"
require "world"

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

	local quit = false
	-- Main loop time.
	while not quit do
		local frameTime = love.timer.getTime()
		-- recompute states
		for i = #state, doldestAction or 1, -1 do
			state[i] = state[i-1]
		end
		for i = oldestAction or 1, 1, -1 do
			state.update(i)
		end

		-- send states to clients
		local p = host:peer_count()
		if p ~= 0 then
			for i = 1, p do
				local peer = host:get_peer(i)
				local ping = peer:round_trip_time()
				local index = math.min(10, math.ceil(ping/2/rate))
				-- local delta = peer.lastAction - index * rate
				-- send state[index], delta
			end
		end

		-- receive actions
		repeat
			local event = host:service((love.timer.getTime() - frameTime) * 100 - 1)
		until love.timer.getTime() - frameTime >= 0.014
		love.timer.sleep(rate/100 - (love.timer.getTime() - frameTime))
	end

	if not love.quit or not love.quit() then
		if love.audio then
			love.audio.stop()
		end
		return
	end
end
function love.load()
	host = enet.host_create("localhost:6789")

	rate = 15
	maxLatency = 300
	local numberOfState = 10
	state = {}
	for i = 1, numberOfState do
		state[i] = {}
	end
end

function love.update(dt)
	-- receive event
	local event = host:service()
	while event do
		if event.type == "receive" then

			local data = event.data
			repeat 
				local type , func, values, rest= data:match("^(%a),([^,]*),([^;]*);(.*)$")
				data = rest
				if type == "a" then
					if func == "sa" then
						local ent = entity.getEntity(event.peer:index())
						ent:setAngle(tonumber(values))
					elseif func == "sv" then
						local ent = entity.getEntity(event.peer:index())
						ent:setVelocity(tonumber(values))
					end
				end
			until data == ""

		elseif event.type == "connect" then
			print(event.peer:index().." connected")
			entity.newEntity(event.peer)
			peers[event.peer:index()] = event.peer
		elseif event.type == "disconnect" then
			print(event.peer:index().." disconnected")
			local ent = entity.getEntity(event.peer:index())
			ent:destroy()
			peers[event.peer:index()] = nil
		end
		event = host:service()
	end

	-- update world
	entity.update(dt)
	collider:update(dt)

	-- snapshot
	if snapshotTime > 0 then
		snapshotTime = snapshotTime - 1
	else
		snapshotTime = initSnapshotTime
		local snapshot = entity.getInformation()

		-- send snapshot
		for index, peer in pairs(peers) do
			peer:send(snapshot)
		end
	end
end
