require "enet"

function love.load()
	host = enet.host_create("localhost:6789")
	peers = {}
	newPeer = function(peer)
		local t = {}
		t.peer = peer
		t.x = math.random(0,10)
		t.y = math.random(0,10)
		t.velocity = 0
		t.angle = 0
		function t:setAngle(a)
			self.angle = a
		end
		function t:setVelocity(v)
			self.velocity = v
		end
		peers[peer:index()] = t
	end
	initSnapshotTime = 5
	snapshotTime = initSnapshotTime
end

function love.update()
	print("server update")
	-- receive event
	local event = host:service()
	while event do
		if event.type == "receive" then
			local data = event.data
			repeat 
				local type , func, values, truc= data:match("^(%a),([^,]*),([^;]*);(.*)$")
				data = truc
				print("data : "..data)
				if type == "a" then
					if func == "sa" then
						peers[event.peer:index()]:setAngle(tonumber(values))
					elseif func == "sv" then
						peers[event.peer:index()]:setVelocity(tonumber(values))
					end
				end
			until data == ""
		elseif event.type == "connect" then
			print(event.peer:index().." connected")
			newPeer(event.peer)
		elseif event.type == "disconnect" then
			print(event.peer:index().." disconnected")
			peer[event.peer:index()] = nil
		end
		event = host:service()
	end

	-- update world
	for index, peer in pairs(peers) do
		if peer.velocity ~= 0 then
			peer.x = peer.x + peer.velocity * math.cos(peer.angle)
			peer.y = peer.y + peer.velocity * math.sin(peer.angle)
		end
	end

	-- snapshot
	if snapshotTime > 0 then
		snapshotTime = snapshotTime - 1
	else
		snapshotTime = initSnapshotTime
		local snapshot = ""
		for index, peer in pairs(peers) do
			snapshot = snapshot..
			peer.peer:index()..
			","..peer.x..
			","..peer.y..
			","..peer.velocity..
			","..peer.angle..
			";"
		end

		-- send snapshot
		for index, peer in pairs(peers) do
			peer.peer:send(snapshot)
		end
	end
end

function love.keypressed(key, isrepeat)
	if key == "escape" then
		love.event.quit()
	end
end
