interpolation = {}

-- this module take use two snapshot to create 3 interpolation between 
-- the two snapshot, accordingly to deltaSnapshot.
--
-- each frame the entity must be deltasolved with the interpolation 
-- corresponding, so the entity are in their location they have 3 
-- frame before
--
-- why 3 and not 4 ?
-- because when a new snapshot arrive, the interpolation.index 
-- is set to zero and then the update will set the entity to the 
-- first interpolation after the second snapshot so 3 frame before
-- the more recent snapshot.

-- the current index of the entity
interpolation.index = 0

interpolation.deltaSnapshot = 4
for i = 1, interpolation.deltaSnapshot do
	interpolation[i] = {}
end

-- initialise the two snapshot to the init snapshot send by the server
function interpolation.newSnapshot(data)
	interpolation.index = 0
	local new = {}

	while data ~= "" do
		local pattern = "^([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^;]*);(.*)$"
		local type,index,x,y,velocity,angle, rest = data:match(pattern)
		assert(type == "e")
		data = rest

		index = tonumber(index)
		x = tonumber(x)
		y = tonumber(y)
		velocity = tonumber(velocity)
		angle = tonumber(angle)

		if index ~= predict.index then
			new[index] = {
				index = index,
				x = x,
				y = y,
				velocity = velocity,
				angle = angle,
			}
		else
			predict.authority = {
				index = index,
				x = x,
				y = y,
				velocity = velocity,
				angle = angle,
			}
		end
	end

	for i,v in pairs(interpolation[interpolation.deltaSnapshot]) do
		if new[i] then
			assert(i ~= predict.index) 
			interpolation[1][i] = {
				x = (new[i].x + 3*v.x)/4,
				y = (new[i].y + 3*v.y)/4,
			}
			interpolation[2][i] = {
				x = (new[i].x + v.x)/2,
				y = (new[i].y + v.y)/2,
			}
			interpolation[3][i] = {
				x = (3*new[i].x + v.x)/4,
				y = (3*new[i].y + v.y)/4,
			}
		end
	end

	interpolation[interpolation.deltaSnapshot] = new
end
