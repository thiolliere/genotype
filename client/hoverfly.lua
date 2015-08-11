local hoverfly = {}

function hoverfly.create()
	local h = {}

	local radius = 10

	h.velocity = 0
	h.state = "0"
	h.shape = collider:addCircle(0, 0, radius)

	-- set methods
	function h:setAngle(angle)
		self.shape:setRotation(angle)
	end

	function h:moveAngle(angle)
		local a = self.shape:getRotation()
		self.shape:setRotation(a + angle)
	end

	function h:getAngle()
		return self.shape:rotation()
	end

	function h:setVelocity(velocity)
		self.velocity = velocity
	end

	function h:getVelocity()
		return self.velocity
	end

	function h:move(x, y)
		self.shape:move(x, y)
	end

	function h:setPosition(x, y)
		self.shape:moveTo(x, y)
	end

	function h:getPosition()
		return self.shape:center()
	end
	
	function h:setX(x)
		local _,y = self.shape:center()
		h:setPosition(x,y)
	end

	function h:setY()
		local x = self.shape:center()
		h:setPosition(x,y)
	end

	function h:getX()
		local x = self.shape:center()
		return x
	end

	function h:getY()
		local _,y = self.shape:center()
		return y
	end

	function h:setState(s)
		self.state = s
	end

	function h:getState()
		return self.state
	end

	function h:update(dt)
		local dx = self.velocity * dt * math.cos(self:getAngle())
		local dy = self.velocity * dt * math.sin(self:getAngle())
		self.shape:move(dx, dy)
	end

	function h:predict(dt)
		h:update(dt)
	end

	function h:destroy()
		collider:remove(self.shape)
		self:setState("0")
	end

	function h:getAttribut()
		local t = {}
		local x,y = self:getPosition()

		t.type = "hoverfly"
		t.x = x
		t.y = y
		t.velocity = self:getVelocity()
		t.angle = self:getAngle()
		t.state = self:getState()

		return t
	end

	function h:draw()
		self.shape:draw()
	end

	function h:setAttribut(att)
		if att.x then
			h:setX(x)
		end
		if att.y then
			h:setY(y)
		end
		if att.velocity then
			h:setVelocity(att.velocity)
		end
		if att.angle then
			h:setAngle(att.angle)
		end
		if att.state then
			h:setState(att.state)
		end
	end

	function h:codeAttribut()
	end

	function h:decodeAttribut(data)
	end
end

function hoverfly.interpolate(from, to, frac)
	if not from or not to then
		return nil
	end

	local t = {}
	for i , v in pairs(from) do
		t[i] = v
	end
	t.x = from.x*frac + to.x*(1-frac) 
	t.y = from.y*frac + to.y*(1-frac) 
	return t
end

function hoverfly.decodeAttribut(data)
	local att = {}
	return att
end

return hoverfly
