action = {}

action.index = 0
action.last = {
	id = 1,
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
	local i = 1
	while action[i].index ~= action.last.index+1 do
		table.remove(action,1)
	end

--	for i = 1, action.last.delta do
--		table.remove(action,1)
--	end
end

function action.send()
	if action[#action].code ~= "" then
		server:send("a"..action[#action].index..";"..action[#action].code)
	end
end

function action.newAction(string)
	action[#action].code = action[#action].code..string
end
