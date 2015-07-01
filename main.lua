require "te.te"

function love.load()
	sound = te.audio.newSource("son.ogg","stream","effect")
	sound:setLooping(true)
	sound:play()
end

function love.update()
	te.audio.update()
end

function love.keypressed(key, isRepeat)
	local x,y,z = te.audio.getPosition()
	if key == "escape" then
		love.event.quit()
	elseif key == "a" then
		te.audio.setPosition(x+2,y,z)
	elseif key == "q" then
		te.audio.setPosition(x-2,y,z)
	elseif key == "z" then
		te.audio.setPosition(x,y+2,z)
	elseif key == "s" then
		te.audio.setPosition(x,y-2,z)
	elseif key == "e" then
		te.audio.setPosition(x,y,z+2)
	elseif key == "d" then
		te.audio.setPosition(x,y,z-2)
	end
end
