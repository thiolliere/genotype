entity = {}

entity.entities= {}

function entity.getEntity(index)
	return entity.entities[index]
end

function entity.getEntities()
	return entity.entities
end

function entity.update(dt)
	for _,ent in pairs(entity.entities) do
		ent:update(dt)
	end
end

function entity.newEntity(peer)
	local e = {}

	-- set attributs
	e.peer = peer
	e.x = 0
	e.y = 0
	e.velocity = 0
	e.angle = 0

	-- set methods
	function e:setAngle(angle)
		self.angle = angle
	end

	function e:getAngle()
		return self.angle
	end

	function e:setVelocity(velocity)
		self.velocity = velocity
	end

	function e:getVelocity()
		return self.velocity
	end

	function e:setPosition(x, y)
		self.x = x
		self.y = y
	end

	function e:getPosition()
		return self.x, self.y
	end

	function e:setPeer(peer)
		self.peer = peer
	end

	function e:getPeer()
		return e.peer
	end

	function e:update(dt)
		self.x = self.x + self.velocity * dt * math.cos(self.angle) 
		self.y = self.y + self.velocity * dt * math.sin(self.angle)
	end

	-- insert entity into structures
	entity.entities[peer:index()] = e
end
