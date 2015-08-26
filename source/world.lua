anim8 = require "lib.anim8"

world = {}
world.HC = require "lib.HardonCollider"

world.object= {}

function world.onCollision(dt, shapeOne, shapeTwo, dx, dy)
	objectOne = shapeOne:getUserData()
	objectTwo = shapeTwo:getUserData()
	objectOne:move(dx/2, dy/2)
	objectTwo:move(-dx/2, -dy/2)
	world.notify(objectOne.index)
	world.notify(objectTwo.index)
end

function world.collisionStop(dt, shapeOne, shapeTwo, dx, dy)
end

world.collider = world.HC.new(100, world.onCollision, world.collisionStop)

-- callable by server only
function world.getNewIndex()
	local p = host:peer_count()
	p = p+1
	while world.object[p] do
		p = p+1
	end
	return p
end

function world.solveDelta(index, table)
	if not world.object[index] and table.type then
		world.object[index] = world[table.type].create(index)
	elseif world.object[index].type ~= table.type then
		world.object[index]:destroy()
		world.object[index] = world[table.type].create(index)
	end
	world.object[index]:setAttribut(table)
end

world.notified = {}
function world.notify(index)
	world.notified[index] = true
end
function world.resetNotify()
	world.notified = {}
	local p = host:peer_count()
	for i = 1,p do
		world.notified[i] = true 
	end
end

function world.encodeObject()
	local data = ""
	for i,_ in pairs(world.notified) do
		local v = world.object[i]
		if not v then
			world.object[i] = world.null.create(i)
			v = world.object[i]
		end
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
	world.collider:update(core.getRate()/1000)
end

function world.draw()
	for _,obj in pairs(world.object) do
		if obj.draw then
			obj:draw()
		end
	end
end

world.hoverfly = require "hoverfly"
world.null = require "null"
world.character = require "character"
