require "enet"
HC = require "HardonCollider"
require "entity"

function onCollision(dt, a, b, dx, dy)
end

function collisionStop(dt, a, b)
end

function love.load()
	host = enet.host_create("localhost:6789")

	collider = HC(100, onCollision, collisionStop)

	peers = {}

	initSnapshotTime = 5
	snapshotTime = initSnapshotTime
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

function love.keypressed(key, isrepeat)
	if key == "escape" then
		love.event.quit()
	end
end
