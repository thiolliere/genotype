genotype.audio = {}

-- this module manage audio, it can be modify as you 
-- want but have to contain some function called by 
-- the main :
-- genotype.audio.setPosition(x,y,z)
-- soundType = "music" or "effect"
-- source = genotype.audio.newSource(filename, type, soundType)
-- source:setPosition()
-- source:setRelative()
-- source:setLooping()
-- source:play()
-- source:pause()
-- source:resume()
-- source:rewind()
-- source:stop()
-- genotype.audio.update()

genotype.audio.volume = {}
genotype.audio.volume.music = 1
genotype.audio.volume.effect = 1
genotype.audio.minAttenuation = 10
genotype.audio.maxAttenuation = 20
genotype.audio.attenuationCoef = 1/(genotype.audio.maxAttenuation - genotype.audio.minAttenuation)
genotype.audio.x = 0
genotype.audio.y = 0
genotype.audio.z = 0

function genotype.audio.newSource (filename, type, soundType)
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
			local xc,yc,zc = genotype.audio.getPosition()
			local xs,ys,zs = self:getPosition()
			x = xs - xc
			y = ys - yc
			z = zs - zc
		else
			x,y,z = self:getPosition()
		end
		local norme2 = math.pow(x,2) + math.pow(y,2) + math.pow(z,2)
		local volume
		if norme2 > math.pow(genotype.audio.maxAttenuation,2) then
			return
		elseif norme2 < math.pow(genotype.audio.minAttenuation,2) then
			volume = 1
		else
			local norme = math.sqrt(norme2)
			local ga = genotype.audio
			volume = 1 - (norme - ga.minAttenuation) * ga.attenuationCoef
		end
		self.source:setVolume(volume * genotype.audio.volume[self.type])
	end

	table.insert(genotype.audio,ts)
	return ts
end

function genotype.audio.setMusicVolume(n)
	genotype.audio.volume.music = n
end

function genotype.audio.setEffectVolume(n)
	genotype.audio.volume.effect = n
end

function genotype.audio.setAttenuation(min, max)
	genotype.audio.minAttenuation = min
	genotype.audio.maxAttenuation = max
	genotype.audio.attenuationCoef = 1/(max - min)
end

function genotype.audio.setPosition(x,y,z)
	genotype.audio.x = x
	genotype.audio.y = y
	genotype.audio.z = z
end

function genotype.audio.getPosition()
	return genotype.audio.x, genotype.audio.y, genotype.audio.z
end

function genotype.audio.update()
	for _,s in ipairs(genotype.audio) do
		s:update()
	end
end
