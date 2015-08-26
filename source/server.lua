require "enet"
require "world"

server = {}
server.clientLastAction = {}
server.rate = 20
do
	local iterator = 0
	server.timeToSendSnapshot = function()
		iterator = iterator - 1
		if iterator <= 0 then
			iterator = 4
			return true
		else
			return false
		end
	end
end

--server.action = {}
--server.action.cursor = 0
--for i = 1, 255 do
--	server.action[i] = ""
--end
--function server.action.newAction(code)
--	server.action[server.action.cursor] = 
--		server.action[server.action.cursor]..string.char(code:len())..code
--end
--function server.action.newIndex()
--	server.action.cursor = server.action.cursor % 255 + 1
--	server.action[server.action.cursor] = ""
--end
--function server.action.get4Past()
--	local cursor = server.action.cursor
--	local data = ""
--	for i = 255-(3-cursor), 255 do
--		local act = server.action[i]
--		local n = act:len()
--		data = data..string.char(math.floor(n/256))..string.char(n%256)..act
--	end
--	for i = math.max(cursor-3,1),cursor do 
--		local act = server.action[i]
--		local n = act:len()
--		data = data..string.char(math.floor(n/256))..string.char(n%256)..act
--	end
--	return data
--end

function love.run()

	if love.math then
		love.math.setRandomSeed(os.time())
		for i=1,3 do love.math.random() end
	end

	do
		host = enet.host_create("localhost:6789")
		for i = 1, 255 do
			world.null.create(i)
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

					local type,lastActionIndex,action = event.data:match("^(.)(.)(.*)$")
					local index = event.peer:index()
					if type == "a" then
						server.clientLastAction[index] = string.byte(lastActionIndex)
						world.object[index]:decodeAction(action)
					end

				elseif event.type == "connect" then

					local index = event.peer:index()
					world.character.create(index)
					server.clientLastAction[index] = 1
					local saveNotify = {}
					for i,v in pairs(world.notified) do
						saveNotify[i] = v
					end
					for i,v in pairs(world.object) do
						world.notify(i)
					end
					event.peer:send(string.char(index)..string.char(server.clientLastAction[index])..world.encodeObject())
					world.notified = saveNotify
					world.notify(index)

				elseif event.type == "disconnect" then

					local index = event.peer:index()
					world.object[index]:destroy()
					server.clientLastAction[index] = nil
					world.notify(index)

				end

				event = host:service()

			end
		end

		world.update(server.rate/1000)

		-- send snapshot
		do
			if server.timeToSendSnapshot() then
				local objectData = world.encodeObject()
				local p = host:peer_count()
				for i = 1, p do
					local peer = host:get_peer(i)
					if peer:state() == "connected" then
						peer:send(string.char(server.clientLastAction[i])..objectData)
					end
				end
				world.resetNotify()
			end
		end

		-- static rate
		do 
			local time = server.rate/1000 - (love.timer.getTime() - frameBeginTime)
			if time < 0 then
				print("!! server rate exceeded !!")
			else
				love.timer.sleep(time)
			end
		end

--		-- draw
--		if love.window and love.graphics and love.window.isCreated() then
--			love.graphics.clear()
--			love.graphics.origin()
--			love.graphics.setBackgroundColor(255,255,255)
--			world.draw()
--			love.graphics.present()
--		end

		-- debug print
		do
			local msg = "\n----------\n\n"
			local p = host:peer_count()
			for i = 1 , p do
				local peer = host:get_peer(i)
				if peer:state() == "connected" then
					t = world.object[i]:getAttribut()
					msg=msg.."peer : index "..i..", lastActionindex "..server.clientLastAction[i].."\n".."--> type="..t.type..",x="..t.x..",y="..t.y.."\n"..
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
