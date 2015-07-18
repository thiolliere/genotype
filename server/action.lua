action = {}

action.lastAction = {}
action.oldest = 1

function action.isValid(peer, data)
	local func = data:byte(1)
	local arg = {}
	for i = 2, data:len() do
		arg[i-1] = data:byte(i)
	end

	if func == 1 or func == 2 then
		if peer:index() == arg[1] and arg[2] then
			return true
		end
	end
	return false
end

function action.load(cardinal)
	for i = 1, cardinal do
		action[i] = {}
	end
end

function action.decode(state, data)
	local func = data:byte(1)
	local arg = {}
	for i = 2, data:len() do
		arg[i-1] = data:byte(i)
	end

	if func == 1 then -- set velocity
		state.entity[arg[1]]:setVelocity(math.min(100, arg[2]))
	elseif func == 2 then -- set angle
		state.entity[arg[1]]:setAngle(arg[2]/256*2*math.pi)
	end
end

function action.indexOfAnteriority(ant)
	return math.max(math.min(#action, math.ceil(ant/rate)), 1)
end
