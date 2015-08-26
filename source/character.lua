local character = {}
character.image = love.graphics.newImage("image/character.png")

local swordAttackTime = 10
local rifleAttackTime = 20
local shiftWeaponTime = 10
local radius = 15
local damageAmount = 1
local visibleRadius = 100

function character.create(index,x,y)
	local h = {}

	h.type = "character"

	if index then 
		h.index = index
	else
		h.index = world.getNewIndex()
	end
		
	h.velocity = 0
	h.state = "swordLeft"
	h.count = 1
	h.life = 1

	h.weaponAngle = 0
	function h:setWeaponAngle(a)
		self.weaponAngle = a
	end
	function h:getWeaponAngle()
		return self.weaponAngle
	end

	h.shape = world.collider:addCircle(x or 0, y or 0, radius)
	function h.shape:getUserData()
		return h
	end

	h.attackSound = love.audio.newSource("sound/hoverflyAttack.wav")
	function h:attack()
		if self.state == "swordLeft" then
			if not mute then
				self.attackSound:play()
			end
			self:setState("swordAttackLeft")
			self.count = 1
		elseif self.state == "swordRight" then
			if not mute then
				self.attackSound:play()
			end
			self:setState("swordAttackRight")
			self.count = 1
		elseif self.state == "rifle" then
			if not mute then
				self.attackSound:play()
			end
			self:setState("rifleAttack")
			self.count = 1
		end
	end

	function h:shiftToSword()
		if self.state == "rifle" then
			self:setState("shiftToSword")
		end
	end

	function h:shiftToRifle()
		if self.state == "swordLeft" or self.state == "swordRight" then
			self:setState("shiftToRifle")
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

		if self.state == "swordAttackLeft" or self.state == "swordAttackRight" then
			world.notify(self.index)
			if self.count >= 1 and self.count < swordAttackTime*3/4 then
				local sx,sy = self:getPosition()
				local sa = self:getAngle()

				local damageHeight = 50
				local possibilty = world.collider:shapesInRange(sx-damageHeight,sy-damageHeight,sx+damageHeight,sy+damageHeight)

				local w1 = 60
				local h = 40
				local w2 = 30
				local x1,y1 = sx-w1/2*math.sin(sa),sy+w1/2*math.cos(sa)
				local x2,y2 = sx+w1/2*math.sin(sa),sy-w1/2*math.cos(sa)
				local x3,y3 = sx+w2/2*math.sin(sa)+h*math.cos(sa),sy-w2/2*math.cos(sa)+h*math.sin(sa)
				local x4,y4 = sx-w2/2*math.sin(sa)+h*math.cos(sa),sy+w2/2*math.cos(sa)+h*math.sin(sa)
				local damageShape = world.collider:addPolygon(x1,y1,x2,y2,x3,y3,x4,y4)

				for i,v in pairs(possibilty) do
					if v:collidesWith(damageShape) then
						other = v:getUserData()
						if other.index ~= self.index and other.damage then
							other:damage(damageAmount)
						end
					end
				end

				world.collider:remove(damageShape)

			elseif self.count >= swordAttackTime then
				if self.state == "swordAttackLeft" then
					self:setState("swordRight")
				else
					self:setState("swordLeft")
				end
			end
		elseif self.state == "rifleAttack"  then
			world.notify(self.index)
			if self.count == 1 then
				local sx,sy = self:getPosition()
				local sa = self:getAngle()

				local damageHeight = 230
				local damageWidth = 2
				local possibilty = world.collider:shapesInRange(sx-damageHeight,sy-damageHeight,sx+damageHeight,sy+damageHeight)

				local x1,y1 = sx-damageWidth/2*math.sin(sa),sy+damageWidth/2*math.cos(sa)
				local x2,y2 = sx+damageWidth/2*math.sin(sa),sy-damageWidth/2*math.cos(sa)
				local x3,y3 = sx+damageWidth/2*math.sin(sa)+damageHeight*math.cos(sa),sy-damageWidth/2*math.cos(sa)+damageHeight*math.sin(sa)
				local x4,y4 = sx-damageWidth/2*math.sin(sa)+damageHeight*math.cos(sa),sy+damageWidth/2*math.cos(sa)+damageHeight*math.sin(sa)
				local damageShape = world.collider:addPolygon(x1,y1,x2,y2,x3,y3,x4,y4)

				for i,v in pairs(possibilty) do
					if v:collidesWith(damageShape) then
						other = v:getUserData()
						if other.index ~= self.index and other.damage then
							other:damage(damageAmount)
						end
					end
				end

				world.collider:remove(damageShape)

			elseif self.count >= rifleAttackTime then
				self:setState("rifle")
			end
		elseif self.state == "shiftToRifle" and self.count >= shiftWeaponTime then
			self:setState("rifle")
		elseif self.state == "shiftToSword" and self.count >= shiftWeaponTime then
			self:setState("swordRight")
		end
		self.count = self.count + 1
	end

	function h:predict(dt)
		local dx = self.velocity * dt * math.cos(self:getAngle())
		local dy = self.velocity * dt * math.sin(self:getAngle())
		self.shape:move(dx, dy)
		if self.state == "rifleAttack"  then
			if self.count >= rifleAttackTime then
				self:setState("rifle")
			end
		elseif self.state == "swordAttackLeft"  then
			if self.count >= swordAttackTime then
				self:setState("swordRight")
			end
		elseif self.state == "swordAttackRight"  then
			if self.count >= swordAttackTime then
				self:setState("swordLeft")
			end
		elseif self.state == "shiftToRifle" and self.count >= shiftWeaponTime then
			self:setState("rifle")
		elseif self.state == "shiftToSword" and self.count >= shiftWeaponTime then
			self:setState("swordRight")
		end
		self.count = self.count + 1
	end

	function h:kill()
		world.notify(self.index)
		self:setVelocity(0)
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
		t.type = "character"
		t.x = x
		t.y = y
		t.velocity = self:getVelocity()
		t.weaponAngle = self:getWeaponAngle()
		t.angle = self:getAngle()
		t.state = self:getState()
		t.count = self.count
		t.life = self.life

		return t
	end

	function h:writeAttribut()
		local v = self:getAttribut()
		return "type="..v.type..",x="..v.x..",y="..v.y..",velocity="..v.velocity..",angle="..v.angle..",state="..v.state..",count="..v.count..",life="..v.life..",weaponAngle="..v.weaponAngle.."\n"
	end

	local g = anim8.newGrid(64, 64, character.image:getWidth(), character.image:getHeight())
	local g2 = anim8.newGrid(4*64, 64, character.image:getWidth(), character.image:getHeight())
	h.animation = {}
	h.animation.swordLeft = anim8.newAnimation(g(2,1), 1)
	h.animation.swordRight = anim8.newAnimation(g(1,1), 1)
	h.animation.swordAttackLeft = anim8.newAnimation(g("1-4",3),swordAttackTime*core.rate/4000)
	h.animation.swordAttackRight = anim8.newAnimation(g("1-4",2),swordAttackTime*core.rate/4000)
	h.animation.rifle = anim8.newAnimation(g(1,4), 1)
	h.animation.rifleAttack = anim8.newAnimation(g2(1,5,1,4), {0.002,1})
	h.animation.dead = anim8.newAnimation(g(1,6), 1)
	h.animation.dead:pauseAtStart()
	h.animation.shiftToSword = anim8.newAnimation(g(3,1), 1)
	h.animation.shiftToRifle = anim8.newAnimation(g(3,1), 1)

	function h:draw()
		if true then
			local x,y = self:getPosition()

			love.graphics.circle("fill",x,y,radius)

			if false then
				love.graphics.setColor(0,125,125)
				local sx,sy = self:getPosition()
				local sa = self:getAngle()

				local damageHeight = 230
				local damageWidth = 2
				local possibilty = world.collider:shapesInRange(sx-damageHeight,sy-damageHeight,sx+damageHeight,sy+damageHeight)

				local x1,y1 = sx-damageWidth/2*math.sin(sa),sy+damageWidth/2*math.cos(sa)
				local x2,y2 = sx+damageWidth/2*math.sin(sa),sy-damageWidth/2*math.cos(sa)
				local x3,y3 = sx+damageWidth/2*math.sin(sa)+damageHeight*math.cos(sa),sy-damageWidth/2*math.cos(sa)+damageHeight*math.sin(sa)
				local x4,y4 = sx-damageWidth/2*math.sin(sa)+damageHeight*math.cos(sa),sy+damageWidth/2*math.cos(sa)+damageHeight*math.sin(sa)
				local damageShape = world.collider:addPolygon(x1,y1,x2,y2,x3,y3,x4,y4)
				love.graphics.polygon("fill",x1,y1,x2,y2,x3,y3,x4,y4)
			end

			if false then --self.state == "attack" and self.count == 2 then
				love.graphics.setColor(125,125,0)
				local sx,sy = self:getPosition()
				local sa = self:getAngle()
				local w1 = 60
				local h = 40
				local w2 = 30
				local x1,y1 = sx-w1/2*math.sin(sa),sy+w1/2*math.cos(sa)
				local x2,y2 = sx+w1/2*math.sin(sa),sy-w1/2*math.cos(sa)
				local x3,y3 = sx+w2/2*math.sin(sa)+h*math.cos(sa),sy-w2/2*math.cos(sa)+h*math.sin(sa)
				local x4,y4 = sx-w2/2*math.sin(sa)+h*math.cos(sa),sy+w2/2*math.cos(sa)+h*math.sin(sa)
				love.graphics.polygon("fill",x1,y1,x2,y2,x3,y3,x4,y4)


			end

		end
		if true then
			local x,y = self:getPosition()
			local a = self:getAngle()
			self.animation[self.state]:draw(character.image,x,y,a,1,1,32,32)
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
		if att.weaponAngle then
			self:setWeaponAngle(att.weaponAngle)
		end
	end

	function h:encodeAttribut()
		return	h:getX()..','..
		h:getY()..','..
		h:getVelocity()..','..
		h:getAngle()..","..
		h:getWeaponAngle()..","..
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
			elseif func == "shS" then
				self:shiftToSword()
			elseif func == "shR" then
				self:shiftToRifle()
			elseif func == "swa" then
				self:setWeaponAngle(tonumber(values))
			end
			world.notify(index)
		end
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

function character.interpolate(from, to, frac)
	if not from then
		return nil
	end

	local t = {}
	for i , v in pairs(from) do
		t[i] = v
	end
	if to.type == "character" then
		t.x = from.x*(1-frac) + to.x*frac 
		t.y = from.y*(1-frac) + to.y*frac 
		t.weaponAngle = from.weaponAngle*(1-frac) + to.weaponAngle
		t.angle = from.angle*(1-frac) + to.angle*frac 

		if from.state == "swordAttackLeft" then
			if from.count + frac*4 >= swordAttackTime then
				t.state = "swordRight"
			end
		end
		if to.state == "swordAttackLeft" then
			if to.count - frac*4 > 0 then
				t.state = "swordAttackLeft"
			end
		end
		if from.state == "swordAttackRight" then
			if from.count + frac*4 >= swordAttackTime then
				t.state = "swordLeft"
			end
		end
		if to.state == "swordAttackRight" then
			if to.count - frac*4 > 0 then
				t.state = "swordAttackRight"
			end
		end
		if from.state == "rifleAttack" then
			if from.count + frac*4 >= swordAttackTime then
				t.state = "rifle"
			end
		end
		if to.state == "rifleAttack" then
			if to.count - frac*4 > 0 then
				t.state = "rifleAttack"
			end
		end


	end
	return t
end

function character.decodeAttribut(data)
	local att = {}
	att.x,att.y,att.velocity,att.angle,att.weaponAngle,att.state,att.count,att.life = data:match(
		"^([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*);$")
	att.x = tonumber(att.x)
	att.y = tonumber(att.y)
	att.velocity = tonumber(att.velocity)
	att.angle = tonumber(att.angle)
	att.weaponAngle = tonumber(att.weaponAngle)
	att.count = tonumber(att.count)
	att.type = "character"
	att.life = tonumber(att.life)
	return att
end

return character
