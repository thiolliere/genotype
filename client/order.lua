order = {}

function order.setAngle(angle)
	server:send("a,sa,"..tostring(angle)..";")
end

function order.setVelocity(velocity)
	server:send("a,sv,"..tostring(velocity)..";")
end
