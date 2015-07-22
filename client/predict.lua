predict = {}

predict.last = {}

predict.index = nil

function predict.isPredicted(index)
	if predict.index == index then
		return true
	else
		return false
	end
end

function predict.cut()
	while predict[1] <= predict.last.index do
		table.remove(predict,1)
	end
end

function predict.diff()
	local predicted = predict[1+predict.last.delta]
	if not predicted then return true end

	local auth = predic.last

	for i,v in pairs(predicted) do
		if auth[i] ~= v then return true end
	end
	return false
end

function predict.reconciliate()
	-- reset the last prediction from the last authority state
	-- it doesn't predict the frame with the action of the frame
end

function predict.predict()
end
