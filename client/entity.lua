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
		i = "e"..
		","..index..
		","..x..
		","..y..
		","..ent.velocity..
		","..ent:getAngle()..
		";"
	end
	return i
end

function entity.newEntity(index,x,y,velocity,angle)
	print("client create entity",index)
	local e = {}

	local x = x or 0
	local y = y or 0
	local radius = 10

	-- set attributs
	e.index = index
	e.velocity = velocity or 0
	e.shape = collider:addCircle(x, y, radius)

	-- set methods
	function e:setAngle(angle)
		self.shape:setRotation(angle)
	end

	if angle then e:setAngle(angle) end

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
	
	function e:getX()
		local x = self.shape:center()
		return x
	end

	function e:getY()
		local _,y = self.shape:center()
		return y
	end

	function e:update(dt)
		local dx = self.velocity * dt * math.cos(self:getAngle())
		local dy = self.velocity * dt * math.sin(self:getAngle())
		e.shape:move(dx, dy)
	end

	function e:destroy()
		collider:remove(self.shape)
		entity[self.index] = false
	end

	function e:getInformation()
		local x,y = self:getPosition()
		local v = self:getVelocity()
		local a = self:getAngle()
		return x,y,v,a
	end

	function e:draw()
		e.shape:draw()
	end

	-- insert entity into structures
	entity[index] = e

end

function entity.solveDelta(index,x,y,v,a)
	if not entity[index] then
		entity.newEntity(index)
	end
	local px,py,pv,pa = entity[index]:getInformation()
	if x and y and (px ~= x or py ~= y) then
		entity[index]:setPosition(x,y)
	end
	if v and pv ~= v then
		entity[index]:setVelocity(v)
	end
	if a and pa ~= a then
		entity[index]:setAngle(a)
	end
end
