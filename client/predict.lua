predict = {}

predict.last = {}

predict.index = nil
predict.authority = nil

function predict.isPredicted(index)
	if predict.index == index then
		return true
	else
		return false
	end
end

function predict.diff()
	local predicted = predict[1]
	if not predicted then return false end

	local auth = predict.authority

	for i,v in pairs(predicted) do
		if math.abs(auth[i] - v)/math.abs(v) > 0.01 then 
			print("diff : "..i.."  "..v)
			return true 
		end
	end
	return false
end

function predict.cut()
	local p = #predict - action.getDeltaSnapFrame()
	for i = 1, p do
		table.remove(predict,1)
	end
end

function predict.reconciliate()
	-- reset the last prediction from the last authority state
	-- it doesn't predict the frame with the action of the frame
	-- but reestimate the last prediction
	
	local auth = predict.authority
	entity.solveDelta(predict.index,auth.x,auth.y,auth.velocity,auth.angle)
	local p = #predict
	for i = 1, p do
		table.remove(predict,1)
	end
	local delta = action.last.delta
	for i = 1, action.getDeltaSnapFrame() - 1 do
		print("predict i :"..i)
		predict.predict(action[i+delta].code)
	end
end

function predict.predict(actionCode)
	-- apply action
	local data = actionCode
	while data ~= "" do
		local func, values, rest= data:match("^([^,]*),([^;]*);(.*)$")
		data = rest
		if func == "sa" then
			entity[predict.index]:setAngle(tonumber(values))
		elseif func == "ma" then
			entity[predict.index]:moveAngle(tonumber(values))
		elseif func == "sv" then
			entity[predict.index]:setVelocity(tonumber(values))
		end
	end

	-- update position
	entity[predict.index]:update(rate/1000)
	-- (resolve collision)

	-- store prediction
	local x,y,v,a = entity[predict.index]:getInformation()
	predict[#predict+1] = {x=x,y=y,velocity=v,angle=a}
end

