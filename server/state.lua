state = {}

function state.load(cardinal)
	for i = 1, cardinal do
		local state[i] = {
			entity = require "entity"
		}
	end
end

function state.update(id)
	-- do action of the state
	for _,data in ipairs(action[id]) do
		action.decode(state[id], data)
	end

	state.entity
	-- update the entities
	-- update the collision
	
end

function state.code(id)
	-- convert state to string
end

function state.indexOfPing(ping)
	return math.max(math.min(#state, math.ceil(ping/2/rate)), 1)
end
