action = {}

action.index = 0
action.last = {
	index = 1,
	delta = 0,
}

function action.newIndex()
	action.index = action.index + 1
	action[#action + 1] = {
		index = action.index,
		code = ""
	}
end

function action.cut()
	while action[1].index <= action.last.index do
		print("cut")
		table.remove(action,1)
	end
end

function action.send()
--	if action[#action].code ~= "" then
		server:send("a"..action[#action].index..";"..action[#action].code)
--	end
end

function action.newAction(string)
	action[#action].code = action[#action].code..string
end

-- number of frame between the last snapshot and the current frame
function action.getDeltaSnapFrame()
	return #action - action.last.delta
end

