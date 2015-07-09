socket = require "socket"

authority = {}

authority = {
	team = {}
}

udp = socket.udp()
udp:settimeout(0)

function authority.addTeam(name)
	authority.team[name] = {
		information = {},
		clients = {},
		entities = {},
	}
end

function authority.removeTeam(name)
	authority.team[name] = nil
end

function authority.addClient(team, name, address, port)
	if not authority.team[team] then
		authority.addTeam(team)
	end
	authority.team[team].clients[client.name] = {
		name = name,
		address = address,
		port = port,
		team = team,
	}
end

function authority.sendInformation()
	for _,team in pairs(authority.team) do
		team.information = {}
		for _,entity in ipairs(team.entities) do
			table.insert(team.information,entity:getInformation())
		end
		for _,client in pairs(team.clients) do
			udp:sendto(team.information, client.address, client.port)
		end
	end
end

function authority.newEntity(owner)
end

function authority.receiveAction()
	repeat
		data, msg_or_ip, port_or_nil = udp:receivefrom()
		if data then
			cmd, params = data:match("^(%S*) (.*)")
			if cmd == "newClient" then
				name, team = params:match("^(%S*) (%S*)$")
				authority.addClient(team, name, msg_or_ip, port_or_nil)
			elseif cmd == "newEntity" then
			elseif cmd == "setAngle" then
			elseif cmd == "setVelocity" then
			else
				print("unrecognised command:", cmd)
			end
		elseif msg ~= 'timeout' then
			error("Network error: "..tostring(msg))
		end
	until not data
end

function authority.update(dt)
	for _,entity in ipairs(authority.entity) do
		entity:update()
	end
	for _,object in ipairs(authority.object) do
		if object:update then
			object:update()
		end
	end
end

function authority.worldupdate()
end

function authority.loop()
	while not quit do
--		authority.receiveAction()
--		authority.updateWorld
--		if t > ... then
--			authority.sendInformation()
--		end
	end
end

function authority.quit()
end
