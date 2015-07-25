world = {}
world.HC = require "lib.HardonCollider"
require "hoverfly"

function world.load()
	world.collider = HC(100, onCollision, collisionStop)
	world.object= {}
end

function world.onCollision(dt, shapeOne, shapeTwo, dx, dy)
end

function world.collisionStop(dt, shapeOne, shapeTwo, dx, dy)
end

function world.solveDelta(index, table)
	if not world.object[index] and table.type then
		world.object[index] = world[table.type].create()
	end
	world.object[index]:setAttribut(table)
end
