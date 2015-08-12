user = {}

if arg[2] and arg[2] == "bot" then
	timeToChange = 0
	function user.update()
		local obj = world.object[core.prediction.index]
		local reposition = 0.3
		local v = 300
		local x = obj:getX()
		local y = obj:getY()
		local w = love.window.getWidth()
		local h = love.window.getHeight()

		if obj:getVelocity() == 0 then
			core.action.newAction("sv,"..v..";")
		end
		if x > w then
			timeToChange = love.timer.getTime() + reposition
			core.action.newAction("sa,"..tostring(math.pi)..";")
		elseif x < 0 then
			timeToChange = love.timer.getTime() + reposition
			core.action.newAction("sa,"..tostring(0)..";")
		elseif y > h then
			timeToChange = love.timer.getTime() + reposition
			core.action.newAction("sa,"..tostring(-math.pi/2)..";")
		elseif y < 0 then
			timeToChange = love.timer.getTime() + reposition
			core.action.newAction("sa,"..tostring(math.pi/2)..";")
		elseif love.timer.getTime() > timeToChange then
			local a = math.random(1,314*2)/100
			core.action.newAction("sa,"..tostring(a)..";")
			timeToChange = love.timer.getTime() + math.random(0.2,2)
		end
	end

else
	function user.update()
		local obj = world.object[core.prediction.index]
		local v = 300
		if love.keyboard.isDown("up") then
			if love.keyboard.isDown("right") then
				local a = -math.pi/4
				if obj:getAngle() ~= a then
					core.action.newAction("sa,"..tostring(a)..";")
				end
				if obj:getVelocity() ~= v then
					core.action.newAction("sv,"..v..";")
				end
			elseif love.keyboard.isDown("left") then
				local a = -math.pi*3/4
				if obj:getAngle() ~= a then
					core.action.newAction("sa,"..tostring(a)..";")
				end
				if obj:getVelocity() ~= v then
					core.action.newAction("sv,"..v..";")
				end
			else
				local a = -math.pi/2
				if obj:getAngle() ~= a then
					core.action.newAction("sa,"..tostring(a)..";")
				end
				if obj:getVelocity() ~= v then
					core.action.newAction("sv,"..v..";")
				end
			end
		elseif love.keyboard.isDown("down") then
			if love.keyboard.isDown("right") then
				local a = math.pi/4
				if obj:getAngle() ~= a then
					core.action.newAction("sa,"..tostring(a)..";")
				end
				if obj:getVelocity() ~= v then
					core.action.newAction("sv,"..v..";")
				end
			elseif love.keyboard.isDown("left") then
				local a = math.pi*3/4
				if obj:getAngle() ~= a then
					core.action.newAction("sa,"..tostring(a)..";")
				end
				if obj:getVelocity() ~= v then
					core.action.newAction("sv,"..v..";")
				end
			else
				local a = math.pi/2
				if obj:getAngle() ~= a then
					core.action.newAction("sa,"..tostring(a)..";")
				end
				if obj:getVelocity() ~= v then
					core.action.newAction("sv,"..v..";")
				end
			end
		elseif love.keyboard.isDown("right") then
			local a = 0
			if obj:getAngle() ~= a then
				core.action.newAction("sa,"..tostring(a)..";")
			end
			if obj:getVelocity() ~= v then
				core.action.newAction("sv,"..v..";")
			end
		elseif love.keyboard.isDown("left") then
			local a = math.pi
			if obj:getAngle() ~= a then
				core.action.newAction("sa,"..tostring(a)..";")
			end
			if obj:getVelocity() ~= v then
				core.action.newAction("sv,"..v..";")
			end
		else
			if obj:getVelocity() ~= 0 then
				core.action.newAction("sv,0;")
			end
		end
	end
end
