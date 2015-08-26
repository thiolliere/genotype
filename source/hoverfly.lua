local hoverfly = {}
hoverfly.image = love.graphics.newImage("image/hoverfly.png")

local attackTime = 10

function hoverfly.create(index,x,y)
	local h = {}

	h.type = "hoverfly"

	local radius = 15
	local damageAmount = 1
	local visibleRadius = 100

	if index then 
		h.index = index
	else
		h.index = world.getNewIndex()
	end
		
	h.velocity = 0
	h.state = "normal"
	h.count = 1
	h.life = 1
	h.shape = world.collider:addCircle(x or 0, y or 0, radius)

	function h.shape:getUserData()
		return h
	end

	h.attackSound = love.audio.newSource("sound/hoverflyAttack.wav")
	function h:attack()
		if self.state == "normal" then
			if not mute then
				self.attackSound:stop()
				self.attackSound:play()
			end
			self:setState("attack")
			self.count = 1
		end
	end

	function h:setAngle(angle)
		if self.state ~= "dead" then
			self.shape:setRotation(angle)
		end
	end

	function h:moveAngle(angle)
		if self.state ~= "dead" then
			local a = self.shape:getRotation()
			self.shape:setRotation(a + angle)
		end
	end

	function h:getAngle()
		return self.shape:rotation()
	end

	function h:setVelocity(velocity)
		if self.state ~= "dead" then
			self.velocity = velocity
		end
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
			self.animation[s]:gotoFrame(1)
			self.state = s
			self.count = 1
		end
	end

	function h:getState()
		return self.state
	end

	function h:update(dt)
		local dx = self.velocity * dt * math.cos(self:getAngle())
		local dy = self.velocity * dt * math.sin(self:getAngle())
		if dx ~= 0 or dy ~= 0 then
			world.notify(self.index)
			self.shape:move(dx, dy)
		end

		if self.state == "attack"  then
			world.notify(self.index)
			if self.count == 1 then
				local sx,sy = self:getPosition()
				local sa = self:getAngle()

				local x1,y1 = sx-32/2*math.sin(sa),sy+32/2*math.cos(sa)
				local x2,y2 = sx+32/2*math.sin(sa),sy-32/2*math.cos(sa)
				local x3,y3 = sx+10/2*math.sin(sa)+20*math.cos(sa),sy-10/2*math.cos(sa)+20*math.sin(sa)
				local x4,y4 = sx-10/2*math.sin(sa)+20*math.cos(sa),sy+10/2*math.cos(sa)+20*math.sin(sa)
				local damageShape = world.collider:addPolygon(x1,y1,x2,y2,x3,y3,x4,y4)
				local possibilty = world.collider:shapesInRange(damageShape:bbox())
				for i,v in pairs(possibilty) do
					if v:collidesWith(damageShape) then
						other = v:getUserData()
						if other.index ~= self.index and other.damage then
							other:damage(damageAmount)
						end
					end
				end

				world.collider:remove(damageShape)

			elseif self.count >= attackTime then
				self:setState("normal")
			end
		end
		self.count = self.count + 1
	end

	function h:predict(dt)
		local dx = self.velocity * dt * math.cos(self:getAngle())
		local dy = self.velocity * dt * math.sin(self:getAngle())
		self.shape:move(dx, dy)
		if self.state == "attack"  then
			if self.count >= attackTime then
				self:setState("normal")
			end
		end
		self.count = self.count + 1
	end

	function h:kill()
		world.notify(self.index)
		self:setVelocity(0)
		world.collider:remove(self.shape)
		self:setState("dead")
	end

	function h:damage(amount)
		world.notify(self.index)
		self.life = self.life-amount
		if self.life <= 0 then
			self:kill()
		end
	end

	function h:destroy()
		world.collider:remove(self.shape)
		world.object[self.index] = nil
	end

	function h:getAttribut()
		local t = {}
		local x,y = self:getPosition()

		t.index = self.index
		t.type = "hoverfly"
		t.x = x
		t.y = y
		t.velocity = self:getVelocity()
		t.angle = self:getAngle()
		t.state = self:getState()
		t.count = self.count
		t.life = self.life

		return t
	end

	function h:writeAttribut()
		local v = self:getAttribut()
		return "type="..v.type..",x="..v.x..",y="..v.y..",velocity="..v.velocity..",angle="..v.angle..",state="..v.state..",count="..v.count..",life="..v.life.."\n"
	end

	local g = anim8.newGrid(64, 64, hoverfly.image:getWidth(), hoverfly.image:getHeight())
	h.animation = {}
	h.animation.normal = anim8.newAnimation(g("1-4",1), 0.05)
	h.animation.attack = anim8.newAnimation(g("1-4",2),attackTime*core.rate/4000)
	h.animation.dead = anim8.newAnimation(g(1,3), 1)
	h.animation.dead:pauseAtStart()

	function h:draw()
		if true then
			if self.state == "normal" then
				love.graphics.setColor(255,0,0)
			elseif self.state == "attack" then
				love.graphics.setColor(0,255,0)
			elseif self.state == "dead" then
				love.graphics.setColor(0,0,255)
			end
			local x,y = self:getPosition()

			love.graphics.circle("fill",x,y,radius)

			if true then --self.state == "attack" and self.count == 2 then
				love.graphics.setColor(125,125,0)
				local sx,sy = self:getPosition()
				local sa = self:getAngle()
				local x1,y1 = sx-32/2*math.sin(sa),sy+32/2*math.cos(sa)
				local x2,y2 = sx+32/2*math.sin(sa),sy-32/2*math.cos(sa)
				local x3,y3 = sx+10/2*math.sin(sa)+20*math.cos(sa),sy-10/2*math.cos(sa)+20*math.sin(sa)
				local x4,y4 = sx-10/2*math.sin(sa)+20*math.cos(sa),sy+10/2*math.cos(sa)+20*math.sin(sa)
				love.graphics.polygon("fill",x1,y1,x2,y2,x3,y3,x4,y4)
			end
		end
		if true then
			local x,y = self:getPosition()
			local a = self:getAngle()
			self.animation[self.state]:draw(hoverfly.image,x,y,a,1,1,32,32)
			self.animation[self.state]:update(0.02)
		end
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
		if att.life then
			self.life = att.life
		end
	end

	function h:encodeAttribut()
		return	h:getX()..','..
		h:getY()..','..
		h:getVelocity()..','..
		h:getAngle()..","..
		h:getState()..","..
		h.count..","..
		h.life..";"
	end

	function h:decodeAction(code)
		local data = code
		while data ~= "" do
			local func, values, rest= data:match("^([^,]*),([^;]*);(.*)$")
			data = rest
			if func == "sa" then
				self:setAngle(tonumber(values))
			elseif func == "ma" then
				self:moveAngle(tonumber(values))
			elseif func == "sv" then
				self:setVelocity(tonumber(values))
			elseif func == "at" then
				self:attack(tonumber(values))
			end
			world.notify(index)
		end
		return ""
	end

	function h:getVisible()
		local sx,sy = self:getPosition()
		local shapes = world.collider:shapeInRange(sx-visibleRadius,sy-visibleRadius,sx+visibleRadius,sy+visibleRadius)
		local obj = {}
		for _,v in pairs(shapes) do
			table.insert(obj,v:getUserData())
		end
		return obj
	end

	world.object[h.index] = h
	return h
end

function hoverfly.interpolate(from, to, frac)
	if not from then
		return nil
	end

	local t = {}
	for i , v in pairs(from) do
		t[i] = v
	end
	if to.type == "hoverfly" then
		t.x = from.x*(1-frac) + to.x*frac 
		t.y = from.y*(1-frac) + to.y*frac 
		t.angle = from.angle*(1-frac) + to.angle*frac 

		if from.state == "attack" then
			if from.count + frac*4 >= attackTime then
				t.state = "normal"
			end
		end
		if to.state == "attack" then
			if to.count - frac*4 > 0 then
				t.state = "attack"
			end
		end
	end
	return t
end

function hoverfly.decodeAttribut(data)
	local att = {}
	att.x,att.y,att.velocity,att.angle,att.state,att.count,att.life = data:match(
		"^([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*);$")
	att.x = tonumber(att.x)
	att.y = tonumber(att.y)
	att.velocity = tonumber(att.velocity)
	att.angle = tonumber(att.angle)
	att.count = tonumber(att.count)
	att.type = "hoverfly"
	att.life = tonumber(att.life)
	return att
end

return hoverfly
