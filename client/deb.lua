deb = {}

deb.compteur = {
	exceeded = 0,
	nonexceeded = 0,
	diff = 0,
	nondiff = 0,
}

function deb.i(label)
	if not deb.compteur[label] then
		deb.compteur[label] = 0
	end
	deb.compteur[label] = deb.compteur[label] + 1
end

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

