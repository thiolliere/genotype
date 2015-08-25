local null = {}

function null.create(index)
	local h = {}

	h.type = "null"

	h.index = index

	function h:predict(dt)
	end

	function h:getType()
		return self.type
	end
	
	function h:destroy()
		world.object[self.index] = nil
	end

	function h:getAttribut()
		local t = {}
		t.type = "null"
		return t
	end

	function h:setAttribut(att)
	end

	function h:encodeAttribut()
		return ";"
	end

	function h:writeAttribut()
		return "type=null"
	end

	return h
end

function null.interpolate(from, to, frac)
	if not from or not to then
		return nil
	end

	local t = {}
	for i , v in pairs(from) do
		t[i] = v
	end
	return t
end

function null.decodeAttribut(data)
	local att = {}
	att.type = "null"
	return att
end

return null
