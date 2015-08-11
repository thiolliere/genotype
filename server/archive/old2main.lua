require "enet"
require "utils"
require "state"

function love.load()
	host = enet.host_create("localhost:6789")

	rate = 15
	halfMaxLatency = 150

	local numberOfState = 10

	state.load(numberOfState)
	action.load(numberOfState)
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
		local frameTime = love.timer.getTime()

		-- recompute states
		for id = #state, action.oldest+1, -1 do
			state[id] = state[id-1]
		end
		state.updateOldest(action.oldest)
		for id = action.oldest-1, 1, -1 do
			state.update(id)
		end

		-- send states to clients
		local p = host:peer_count()
		if p ~= 0 then
			for i = 1, p do
				local peer = host:get_peer(i)
				local ping = peer:round_trip_time()
				local stateIndex = state.indexOfPing(ping)
				local lastAction = action.lastAction[peer:index()]
				local delta = math.floor(frameTime*100 - (index-1)*rate - lastAction.time*100) -- delta between last action and the time of the state in ms

				local snapshotCode = state.code(stateIndex)..
					action.codeFrom(stateIndex-1)..
					string.2char(delta)..
					string.char(lastAction.id)

				peer:send(snapshotCode)
			end
		end

		-- shift actions
		for i = #action, 2, -1 do
			action[i] = action[i - 1]
		end
		action[1] = {}
		action.oldest = 1

		-- receive actions
		repeat
			local event = host:service((love.timer.getTime() - frameTime) * 100 - 1)
			if event.type == "receive" then

				if event.data:len() > 1 then
					local id = event.data:byte(1)
					local peerAction = event.data:sub(2)
					local peer = event.peer
					local ping = peer:round_trip_time()
					local actionIndex = action.indexOfAnteriority(ping/2)

					action.lastAction[peer:index()] = {time = love.timer.getTime(), id = id}

					if actionIndex > action.oldest then
						action.oldest = actionIndex
					end

					if action.isValid(event.peer, data) then
						table.insert(action[actionIndex], peerAction)
					end
				end

			elseif event.type == "connect" then

				print(event.peer:index().." connected")

			elseif event.type == "disconnect" then

				print(event.peer:index().." disconnected")

			end

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
