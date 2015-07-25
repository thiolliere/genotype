core = {}

core.snapshot = {}

function core.snapshot.decode(data)
	new = {}

	local new.lastAction,rest = data:match("^([^;]*);(.*)$")
	data = rest

	while data ~= "" do
		local t = {}
		local t.type,t.index,t.att,t.rest = data:match("^([^,]*),([^,]*),([^;]*);(.*)$")
		data = rest

		new[tonumber(index)] = t
	end
	return new
end

function core.setRate(rate)
	core.rate = rate
end

function core.getRate()
	return core.rate
end

function core.snapshot.setDelta(delta)
	core.snapshot.delta = delta
end

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

function core.snapshot.completeSnap(deltaSnap, fromSnap)
	for i,v in pairs(fromSnap.object) do
		if not deltaSnap.object[i] then
			deltaSnap.object[i] = v
		end
	end
end

core.prediction = {}

function core.prediction.setAuthority(auth)
	core.prediction.authority = auth
end

function core.snapshot.removeIndex(index, snap)
	local i = snap.object[index]
	snap.object[index] = nil
	return i
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
	core.interpolation = 1
end

function core.interpolation.incCursor()
	core.interpolation = core.interpolation + 1
end

function core.prediction.reconiliate(snap)
	local n = #core.prediction
	for i = 1, n do
		table.remove(core.prediction, 1)
	end

	core.prediction[1] = snap.object[core.prediction.getIndex()]
	for i = 1, #core.action do
		core.prediction.predict(core.action[1].code)
	end
end

function core.prediction.predict(code)
	core.action.apply(code)
	world[core.prediction.index]:update()

	predict[#predict+1] = world[core.prediction.index]:getAttribut()
end


































function core.interpolate(fromSnap, toDSnap)
end

core.snapshot.last = {}

function core.snapshot.decode(data)
end

function core.snapshot.setRate(rate)
end

function core.snapshot.removeIndex(index, snap)
end

function core.snapshot.getLast()
end

function core.snapshot.completeSnap(dsnap, snap)
end

-- a snapshot is table with :
--	lastAction
--	object = {}
--	(delta)

function core.diffObject(a, b)
end


core.prediction= {}

function core.prediction.predict()
end

function core.prediction.getPrediction()
end

function core.prediction.cut(n)
end

function core.prediction.setIndex(index)
end

function core.prediction.reconciliate(snap) 
end

function core.prediction.getIndex()
end

function core.interpolation.interpolate(from, to)
end

function core.interpolation.initCurrent()
end

function core.interpolation.incrementCurrent()
