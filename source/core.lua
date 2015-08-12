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

function core.snapshot.encodeSnap(lastAction,objectData)
	return lastAction..";"..objectData
end

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
		local lastAction,objectCode = data:match("^([^;]*);(.*)$")
		self:setLastAction(tonumber(lastAction))
		self:setObject(world.decodeObject(objectCode))
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

function core.prediction.getAuthority()
	return core.prediction.authority
end

function core.prediction.reconciliate(snap)
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
	world.object[core.prediction.index]:predict(core.getRate()/1000)

	core.prediction[#core.prediction+1] = world.object[core.prediction.index]:getAttribut()
end

function core.prediction.getPrediction()
	return core.prediction[#core.prediction]
end

function core.prediction.cut(n)
	for i = 1,n do
		table.remove(core.prediction,1)
	end
end

function core.prediction.diff()
	local auth = core.prediction.getAuthority()
	local pred = core.prediction[1]
	for i,v in pairs(auth) do
		if pred[i] ~= v then
			return true
		end
	end
	return false
end


core.interpolation = {}

-- require core.rate
function core.interpolation.interpolate(from, to)
	local n = #core.interpolation
	for i = 1, n do
		table.remove(core.interpolation,1)
	end

	local delta = core.snapshot.getDelta()
	for i = 1, delta do
		core.interpolation[i] = {}
	end

	for i,v in pairs(from.object) do
		-- assert(i ~= predict.index) 
		for i,a in pairs(v) do
			print(a)
		end
		for j = 1, delta do
			core.interpolation[j][i] = world[v.type].interpolate(v, 
						     to.object[i], 
						     j/delta)
		end
	end
end


function core.interpolation.initCursor()
	core.interpolation.cursor = 1
end

function core.interpolation.incCursor()
	core.interpolation.cursor = math.min(core.interpolation.cursor + 1,core.snapshot.getDelta())
end

core.action = {}

core.action.index = 0

function core.action.newIndex()
	core.action.index = core.action.index + 1
	core.action[#core.action + 1] = {
		index = core.action.index,
		code = ""
	}
end

function core.action.cutToIndex(index)
	while core.action[1].index and core.action[1].index <= index do
		table.remove(core.action,1)
	end
end


function core.action.send()
	server:send("a"..core.action[#core.action].index..";"..core.action[#core.action].code)
end

function core.action.apply(code)
	local data = code
	local index = core.prediction.getIndex()
	while data ~= "" do
		local func, values, rest= data:match("^([^,]*),([^;]*);(.*)$")
		data = rest
		if func == "sa" then
			world.object[index]:setAngle(tonumber(values))
		elseif func == "ma" then
			world.object[index]:moveAngle(tonumber(values))
		elseif func == "sv" then
			world.object[index]:setVelocity(tonumber(values))
		end
	end
end

function core.action.getLastAction()
	return core.action[#core.action]
end

function core.action.newAction(code)
	core.action[#core.action].code = core.action[#core.action].code..code
end
