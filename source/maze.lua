maze = {}

function maze.generateMap()
	local meanHoverfly = 1
	local stddevHoverfly = 1

	local path
	repeat
		path = maze.generatePath()
	until path ~= false

	for i,p in ipairs(path) do
		maze.generateRoom(p.prec,p.suiv)
	end



end

function maze.generatePath()
	local numberOfRoom = 5

	local room = {{x=1,y=1,prec=false}}

	function room.isFree(x,y)
		for _,r in ipairs(room) do
			if r.x == x and r.y == y then
				return false
			end
		end
		return true
	end

	for i = 1, numberOfRoom do
		local count = 0
		while #room <= i do

			count = count + 1
			if count > 30 then return false end

			local rdm = love.math.random(4)
			local x,y = room[i].x, room[i].y
			local dir
			if rdm == 1 and room.isFree(x-1,y) then
				room[i+1] = {x=x-1,y=y,prec="down"}
				room[i].suiv = "up"
			elseif rdm == 2 and room.isFree(x+1,y) then
				room[i+1] = {x=x+1,y=y,prec="up"}
				room[i].suiv = "down"
			elseif rdm == 3 and room.isFree(x,y-1) then
				room[i+1] = {x=x,y=y-1,prec="right"}
				room[i].suiv = "left"
			elseif rdm == 4 and room.isFree(x,y+1) then
				room[i+1] = {x=x,y=y+1,prec="left"}
				room[i].suiv = "right"
			end
		end
	end
	room[#room].suiv = false
	
	local minx,miny = room[1].x, room[1].y
	for _,r in ipairs(room) do
		if r.x < minx then
			minx = r.x
		end
		if r.y < miny then
			miny = r.y
		end
	end

	local min = math.min(minx,miny)
	if min <= 0 then
		local delta = -min + 1
		for i,r in ipairs(room) do
			r.x = r.x + delta
			r.y = r.y + delta
		end
	end

	return room
end

function maze.generateRoom(prec,suiv)
	local roomMaxDim = 6

	local room = {}
	room.height = love.math.random(roomMaxDim)
	room.width = love.math.random(roomMaxDim)

	local table = {up=1,down=room.height,left=1,right=room.width}
	if prec == "up" or prec == "down" then
		room.enter = {x=love.math.random(room.width),y=table[prec]}
	else
		room.enter = {y=love.math.random(room.height),x=table[prec]}
	end
	if suiv == "up" or suiv == "down" then
		room.exit = {x=love.math.random(room.width),y=table[suiv]}
	else
		room.exit = {y=love.math.random(room.height),x=table[suiv]}
	end

	local topleft = {}

	return room
end

