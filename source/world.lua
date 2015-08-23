world = {}
world.HC = require "lib.HardonCollider"

world.object= {}

function world.onCollision(dt, shapeOne, shapeTwo, dx, dy)
	objectOne = shapeOne:getUserData()
	objectTwo = shapeTwo:getUserData()
	objectOne:move(dx/2, dy/2)
	objectTwo:move(-dx/2, -dy/2)
end

function world.collisionStop(dt, shapeOne, shapeTwo, dx, dy)
end

world.collider = world.HC.new(100, world.onCollision, world.collisionStop)

function world.solveDelta(index, table)
	if not world.object[index] and table.type then
		world.object[index] = world[table.type].create(index)
	end
	world.object[index]:setAttribut(table)
end

function world.encodeObject()
	local data = ""
	for i,v in pairs(world.object) do
		data = data..i..","..v.type..","..v:encodeAttribut()
	end
	return data
end

function world.decodeObject(data)
	local object = {}
	while data ~= "" do
		local index,type,att,rest = data:match("^([^,]*),([^,]*),([^;]*;)(.*)$")
		data = rest

		object[tonumber(index)] = world[type].decodeAttribut(att)
	end
	return object
end

function world.update(dt)
	for i,v in pairs(world.object) do
		if v.update then
			v:update(dt)
		end
	end
	world.collider:update(rate/1000)
end

world.hoverfly = require "hoverfly"
