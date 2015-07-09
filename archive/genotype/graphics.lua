genotype.graphics = {}

-- this module manage the draw of objects.
-- it must provide the following functions :
--
-- sprite = genotype.graphics.newSprite (living)
-- sprite:setPosition(x, y, z)
-- sprite:setLevel(level)
-- psrite:setAngle(r)
-- state = "stay" or "run" or "attack" or "defend"
-- sprite:setState(state)
-- sprite:setLooping(boolean)
-- weapon = "none" or "sword" or ..
-- sprite:setWeapon(weapon)
-- genotype.graphics.update(dt)
-- genotype.graphics.draw()
--
--( effectname = "touched" "killed"
-- genotype.graphics.newEffect(level, x, y, z, r, effectname))




