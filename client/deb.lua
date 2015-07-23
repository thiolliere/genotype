deb = {}

deb.timer = {}

function deb.b(label)
	deb.timer[label] = love.timer.getTime()
end

function deb.e(label)
	deb.timer[label] = love.timer.getTime() - deb.timer[label]
end

function deb.p()
	for i,v in pairs(deb.timer) do
		print("timer for ",i," : ",v)
	end
end

