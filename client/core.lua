core = {}

-- set the rate of the main loop
function core.setRate(rate)
	core.rate = rate
end

-- get the rate of the main loop
function core.getRate()
	return core.rate
end

-- module that manage snapshot 
--
-- a snapshot is table with :
--	lastAction
--	object = {}
--	(delta)
core.snapshot = {}

function core.snapshot.createSnap()
	local snap = {object = {}}

	function snap:getObject()
		return self.object
	end

	function snap:setObject(obj)
		self.object = obj
	end

	function snap:completeFrom(fromSnap)
		local fromObject = fromSnap:getObject()
		local toObject = self:getObject()

		for i,v in pairs(fromObject) do
			if not toObject[i] then
				toObject[i] = v
			end
		end
	end

	function snap:decode(data)
		local lastAction,rest = data:match("^([^;]*);(.*)$")
		data = rest
		self:setLastAction(lastAction)

		local object = {}
		while data ~= "" do
			local index,name,att,rest = data:match("^([^,]*),([^,]*),([^;]*);(.*)$")
			data = rest

			object[tonumber(index)] = world[name].decodeAttribut(att)
		end

		self:setObject(object)
	end

	function snap:removeIndex(index)
		local i = self.object[index]
		self.object[index] = nil
		return i
	end

	function snap:setLastAction(act)
		self.lastAction = act
	end

	function snap:getLastAction()
		return self.lastAction
	end

	return snap
end

for i = 1,2 do
	core.snapshot[i] = core.snapshot.createSnap()
end
core.snapshot.new = 1

function core.snapshot.newSnap(data)
	core.snapshot.new = core.snapshot.new % 2 + 1
	local old, new = core.snapshot.getSnap()

	new:decode(data)
	new:completeFrom(old)
end

function core.snapshot.getSnap()
	return core.snapshot.getOld(), core.snapshot.getNew()
end

function core.snapshot.getNew()
	return core.snapshot[core.snapshot.new]
end

function core.snapshot.getOld()
	return core.snapshot[core.snapshot.new % 2 + 1]
end

-- set the delta between server state and local state
function core.snapshot.setDelta(delta)
	core.snapshot.delta = delta
end

-- get the delta between server state and local state
function core.snapshot.getDelta()
	return core.snapshot.delta
end


core.prediction = {}

function core.prediction.setIndex(index)
	core.prediction.index = index
end

function core.prediction.getIndex(index)
	return core.prediction.index
end

function core.prediction.setAuthority(auth)
	core.prediction.authority = auth
end

function core.prediction.reconiliate(snap)
	local n = #core.prediction
	for i = 1, n do
		table.remove(core.prediction, 1)
	end

	core.prediction[1] = core.prediction.authority
	for i = 1, #core.action do
		core.prediction.predict(core.action[1].code)
	end
end

function core.prediction.predict(code)
	core.action.apply(code)
	world[core.prediction.index]:predict(core.getRate())

	predict[#predict+1] = world[core.prediction.index]:getAttribut()
end


core.interpolation = {}

-- require core.rate
function core.interpolation.interpolate(from, to)
	local n = #core.interpolation
	for i = 1, n do
		table.remove(core.interpolation,1)
	end

	for i,v in pairs(from.object) do
		-- assert(i ~= predict.index) 
		local delta = core.snapshot.getDelta()
		for i = 1, delta do
			core.interpolation[i] = world[v.type].interpolate(v, 
						     to.object[i], 
						     i/delta)
		end
	end
end


function core.interpolation.initCursor()
	core.interpolation.cursor = 1
end

function core.interpolation.incCursor()
	core.interpolation.cursor = core.interpolation.cursor + 1
end

core.action = {}

function core.action.newIndex()
	action.index = action.index + 1
	action[#action + 1] = {
		index = action.index,
		code = ""
	}
end

function core.action.cutToIndex(index)
	while action[1].index and action[1].index <= index do
		table.remove(action,1)
	end
end


