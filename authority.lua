socket = require "socket"

authority = {}

authority = {
	snapshotRate = 0.1,
	map = "defaultMap",
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

function authority.addClient(team, client)
	if not authority.team[team] then
		authority.addTeam(team)
	end
	authority.team[team][clients][client.name] = {
	      name = client.name,
	      address = client.address, 
	      port = client.port,
	      entities = client.entites
      }
end

--function authority.addEntities
--end

function authority.launch()
	authority.addClient("red", {name = "Joe", address = "localhost", port = "12345"})
	authority.addClient("blue", {name = "Jack", address = "localhost", port = "12346"})
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

function authority.receiveAction()
	udp:receivefrom()
	-- boucle sur les message recu
	-- verifie leur validité et enclenche leur actions 
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
