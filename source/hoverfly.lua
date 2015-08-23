local hoverfly = {}

function hoverfly.create()
	local h = {}

	h.type = "hoverfly"

	local radius = 10
	local damageWidth = 2
	local damageHeight = 6

	h.velocity = 0
	h.state = "normal"
	h.count = 1
	h.shape = world.collider:addCircle(0, 0, radius)
	function h.shape:getUserData()
		return h
	end

	-- set methods
	function h:attack()
		if self.state == "normal" then
			self.state = "attack"
			self.count = 1
		end
	end

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

	function h:setY(y)
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
		if self.state ~= s then
			self.state = s
			self.count = 1
		end
	end

	function h:getState()
		return self.state
	end

	function h:update(dt)
		if self.state ~= "dead" then
			local dx = self.velocity * dt * math.cos(self:getAngle())
			local dy = self.velocity * dt * math.sin(self:getAngle())
			self.shape:move(dx, dy)

			if self.state == "attack"  then
				if self.count == 1 then
					local sx,sy = self:getPosition()
					local sa = self:getAngle()

					local possibilty = world.collider:shapesInRange(sx-damageHeight,sy-damageHeight,sx+damageHeight,sy+damageHeight)

					local x1,y1 = sx+damageWidth/2*math.sin(sa),sy+damageWidth/2*math.cos(sa)
					local x2,y2 = sx-damageWidth/2*math.sin(sa),sy-damageWidth/2*math.cos(sa)
					local x3,y3 = x2+damageHeight*math.cos(sa),y2+damageHeight*math.sin(sa)
					local x4,y4 = x1+damageHeight*math.cos(sa),y1+damageHeight*math.sin(sa)
					--print(x1,y1,x2,y2,x3,y3,x4,y4)
					local damageShape = world.collider:addPolygon(x1,y1,x2,y2,x3,y3,x4,y4)

					for i,v in ipairs(possibilty) do
						if v:collidesWith(damageShape) then
							v:kill()
						end
					end

					world.collider:remove(damageShape)

				elseif self.count >= 6 then
					self:setState("normal")
				end
			end
		end
		self.count = self.count + 1
	end

	function h:predict(dt)
		h:update(dt)
	end

	function h:kill()
		self:setState("dead")
	end

	function h:destroy()
		world.collider:remove(self.shape)
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
		t.count = self.count

		return t
	end

	function h:draw()
		if self.state == "normal" then
			love.graphics.setColor(255,0,0)
		elseif self.state == "attack" then
			love.graphics.setColor(0,255,0)
		elseif self.state == "dead" then
			love.graphics.setColor(0,0,255)
		end
		local x,y = self:getPosition()
		love.graphics.circle("fill",x,y,radius)
--		self.shape:draw()
	end

	function h:setAttribut(att)
		if att.x then
			self:setX(att.x)
		end
		if att.y then
			self:setY(att.y)
		end
		if att.velocity then
			self:setVelocity(att.velocity)
		end
		if att.angle then
			self:setAngle(att.angle)
		end
		if att.state then
			self:setState(att.state)
		end
		if att.count then
			self.count = att.count
		end
	end

	function h:encodeAttribut()
		return	h:getX()..','..
		h:getY()..','..
		h:getVelocity()..','..
		h:getAngle()..","..
		h:getState()..","..
		h.count..";"
	end

	return h
end

function hoverfly.interpolate(from, to, frac)
	if not from or not to then
		return nil
	end

	local t = {}
	for i , v in pairs(from) do
		t[i] = v
	end
	t.x = from.x*(1-frac) + to.x*frac 
	t.y = from.y*(1-frac) + to.y*frac 
	return t
end

function hoverfly.decodeAttribut(data)
	local att = {}
	att.x,att.y,att.velocity,att.angle,att.state,att.count = data:match(
		"^([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*);$")
	att.x = tonumber(att.x)
	att.y = tonumber(att.y)
	att.velocity = tonumber(att.velocity)
	att.angle = tonumber(att.angle)
	att.count = tonumber(att.count)
	att.type = "hoverfly"
	return att
end

return hoverfly
