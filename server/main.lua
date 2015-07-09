require "enet"
require "entity"
HC = require "hardoncollider"

function onCollision(dt, a, b, x, y)
end

function collisionStop(dt, a, b)
end

function love.load()
	host = enet.host_create("localhost:6789")

	collider = HC(100, onCollision, collisionStop)

	initSnapshotTime = 5
	snapshotTime = initSnapshotTime
end

function love.update()
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
