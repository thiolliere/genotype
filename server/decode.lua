require "entity"

function decode(string, peer)
	local func, values = data:match("^([^,]*),([^;]*);.*$")
	local ent = entity.getEntity(peer:index())
	if func == "sa" then
		ent:setAngle(tonumber(values))
	elseif func == "sv" then
		ent:setVelocity(tonumber(valuse))
	end
end
