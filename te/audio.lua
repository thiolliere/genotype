te.audio = {}

te.audio.volume = {}
te.audio.volume.music = 1
te.audio.volume.effect = 1
te.audio.minAttenuation = 10
te.audio.maxAttenuation = 20
te.audio.attenuationCoef = 1/(te.audio.maxAttenuation - te.audio.minAttenuation)
te.audio.x = 0
te.audio.y = 0
te.audio.z = 0

-- soundType	"music" or "effect"
function te.audio.newSource (filename, type, soundType)
	local ts = {}
	ts.source = love.audio.newSource (filename, type)

	ts.type = soundType or "effect"

	function ts:getSoundType()
		return self.type
	end

	ts.x = 0
	ts.y = 0
	ts.z = 0

	function ts:setPosition(x,y,z)
		self.x = x
		self.y = y
		self.z = z
	end

	function ts:getPosition()
		return self.x,self.y,self.z
	end

	ts.relative = false

	function ts:setRelative(bool)
		self.relative = bool
	end

	ts.looping = false

	function ts:setLooping(bool)
		self.source:setLooping(bool)
	end

	function ts:getLooping()
		return self.source:getLooping()
	end

	function ts:play()
		self.source:play()
	end

	function ts:pause()
		self.source:pause()
	end

	function ts:resume()
		self.source:resume()
	end

	function ts:stop()
		self.source:stop()
	end 

	function ts:rewind()
		self.source:rewind()
	end

	function ts:update()
		local x,y,z
		if  not self.relative then
			local xc,yc,zc = te.audio.getPosition()
			local xs,ys,zs = self:getPosition()
			x = xs - xc
			y = ys - yc
			z = zs - zc
		else
			x,y,z = self:getPosition()
		end
		local norme2 = math.pow(x,2) + math.pow(y,2) + math.pow(z,2)
		local volume
		if norme2 > math.pow(te.audio.maxAttenuation,2) then
			return
		elseif norme2 < math.pow(te.audio.minAttenuation,2) then
			volume = 1
		else
			local norme = math.sqrt(norme2)
			local ta = te.audio
			volume = 1 - (norme - ta.minAttenuation) * ta.attenuationCoef
		end
		self.source:setVolume(volume * te.audio.volume[self.type])
	end

	table.insert(te.audio,ts)
	return ts
end

function te.audio.setMusicVolume(n)
	te.audio.volume.music = n
end

function te.audio.setEffectVolume(n)
	te.audio.volume.effect = n
end

function te.audio.setAttenuation(min, max)
	te.audio.minAttenuation = min
	te.audio.maxAttenuation = max
	te.audio.attenuationCoef = 1/(max - min)
end

function te.audio.setPosition(x,y,z)
	te.audio.x = x
	te.audio.y = y
	te.audio.z = z
end

function te.audio.getPosition()
	return te.audio.x, te.audio.y, te.audio.z
end

function te.audio.update()
	for _,s in ipairs(te.audio) do
		s:update()
	end
end
