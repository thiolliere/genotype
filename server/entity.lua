entity = {}

function entity.update(dt)
	for _,ent in ipairs(entity) do
		ent:update(dt)
	end
end

function entity.getInformation()
	local i = ""
	for index, ent in ipairs(entity) do
		local x, y = ent:getPosition()
		i = i..
			"e"..
			","..index..
			","..x..
			","..y..
			","..ent.velocity..
			","..ent:getAngle()..
			";"
	end
	return i
end

function entity.newEntity(peer)
	local e = {}

	local x = 0
	local y = 0
	local radius = 10

	-- set attributs
	e.peer = peer
	e.velocity = 0
	e.shape = collider:addCircle(x, y, radius)

	-- set methods
	function e:setAngle(angle)
		self.shape:setRotation(angle)
	end

	function e:moveAngle(angle)
		local a = self.shape:getRotation()
		self.shape:setRotation(a + angle)
	end
	function e:getAngle()
		return self.shape:rotation()
	end

	function e:setVelocity(velocity)
		self.velocity = velocity
	end

	function e:getVelocity()
		return self.velocity
	end

	function e:move(x, y)
		self.shape:move(x, y)
	end

	function e:setPosition(x, y)
		self.shape:moveTo(x, y)
	end

	function e:getPosition()
		return self.shape:center()
	end

	function e:setPeer(peer)
		self.peer = peer
	end

	function e:getPeer()
		return e.peer
	end

	function e:update(dt)
		local dx = self.velocity * dt * math.cos(self:getAngle())
		local dy = self.velocity * dt * math.sin(self:getAngle())
		e.shape:move(dx, dy)
	end

	function e:destroy()
		collider:remove(self.shape)
		entity[self.peer:index()] = nil
	end

	-- insert entity into structures
	entity[peer:index()] = e
end
