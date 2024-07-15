pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--dimensional delights           v0.1.0
--mini mech media


gs = nil

dirs = {
	left = 0,
	right = 1,
	up = 2,
	down = 3,
	z = 4,
	x = 5
}
debug = false
gameOverWin = 'win'
gameOverLose = 'lose'

function makeSmokeParticle(pos, vel)
    local smokeParticle = {
        pos = pos,
        vel = vel,
		age = 0,
		phase = rnd(),
        update = function(self)
            -- self.pos = self.pos + self.vel
			self.age += 1
        end,
        draw = function(self)
			local effpos = pos + vec2((1+self.age/40)*sin(self.age/50+self.phase), -self.age/10)
			-- local colormap = {
			-- 	0,
			-- 	-- 1,
			-- 	-- 5,
			-- 	-- 13,
			-- 	6
			-- }
			circfill(effpos.x, effpos.y, 1+self.age/100, 
				0)
			-- colormap[self.age\100+1])
            -- pset(self.pos.x, self.pos.y, 7) -- Draw the particle as a white pixel
        end
    }
    return smokeParticle
end


function makeLauncher(pos)
    local launcher = {
        pos = pos,
		isBroken = false,
		health = 1,
		iceCream = makeIceCream(pos+vec2(0,-11), vec2(0,0)),
		-- iceCream = nil,
		coolDown = rnd(100/gs.level.spawnRate),
		maxCoolDown = 100/gs.level.spawnRate,
		particles = {},
		breakIt = function(self)
			self.isBroken = true
			self.health = 0
			-- self.iceCream = nil
		end,
		fixIt = function(self)
			self.isBroken = false
			self.particles = {}
			self.coolDown = self.maxCoolDown
			gs.player.isfixing = false

		end,
		-- shouldShoot = false,
        update = function(self)
			if not gs:isFreaky() and not self.isBroken and rnd(1000) < .5 and not gs:shouldLevelUp() then
				self:breakIt()
			end
			if not self.isBroken then
				-- if self.coolDown 
				if self.coolDown > 0 then
					self.coolDown -= 1
					-- if self.coolDown < self.maxCoolDown/2 and self.iceCream == nil then
					-- 	self.iceCream = makeIceCream(pos+vec2(0,-8), vec2(0,0))
					-- end

					-- if self.coolDown < 10 and self.iceCream == nil then
					-- 	self.iceCream = makeIceCream(pos+vec2(0,-8), vec2(0,30))
					-- end
				-- elseif self.iceCream != nil and rnd() < 0.01 then
				-- elseif rnd() < gs.level.spawnRate / 100 then
				else
					add(gs.projectiles, makeIceCream(pos+vec2(0,-8), vec2(0,gs.level.speed)))
					-- self.iceCream = nil
					self.coolDown = self.maxCoolDown/2 + rnd(self.maxCoolDown)/2
				end
			end


			if self.isBroken then
				if rnd() < .1 then
					add(self.particles, makeSmokeParticle(pos))
				end
				while #self.particles > 30 do
					deli(self.particles, 1)
				end
			end

			if gs.player.pos:taxiDist(self.pos) <= 20 then
				if self.isBroken and not gs:isFreaky() then
					-- assert(false)
					self.health += 0.01
					self.health = min(self.health, 1)
					if self.health >= 1 then
						self:fixIt()
					end
					self.isfixing = true
				elseif gs:isFreaky() and not self.isBroken then
					self.health -= 0.01
					self.health = max(self.health, 0)
					if self.health <=0 then
						self:breakIt()
					end
					self.isfixing = true
				else
					self.isfixing = false
				end
			else
				self.isfixing = false
			end

            for particle in all(self.particles) do
                particle:update()
            end
            -- makeIceCream(self.pos, vec2(0, -1))
        end,
        draw = function(self)
			local sprite = 36
			if gs:isFreaky() then
				sprite = 2
			end
            spr(sprite, self.pos.x-8, self.pos.y-8, 2,2 )
			-- circ(self.pos.x, self.pos.y-8, 8*(self.maxCoolDown -self.coolDown)/self.maxCoolDown, 9)
			local scale = (self.maxCoolDown -self.coolDown)/self.maxCoolDown
			scale = min(scale+.1,1)
				-- spr(4, self.pos.x-8)
			if not self.isBroken then
				self.iceCream:draw(scale)
			end

			if self.isBroken or gs:isFreaky() then
				local healthBarWidth = 12
				local healthBarHeight = 2
				local healthBarX = self.pos.x - healthBarWidth / 2
				local healthBarY = self.pos.y + 10
				local colorMap = {
					8,
					8,
					9,
					9,
					10,
					10,
					-- 3,
					-- 3,
					11,
				}
				local healthBarColor = colorMap[min(self.health*#colorMap\1+1,#colorMap)]

				-- Draw the background of the health bar
				rectfill(healthBarX, healthBarY, healthBarX + healthBarWidth, healthBarY + healthBarHeight, 0)

				-- Draw the health portion of the health bar
				rectfill(healthBarX, healthBarY, healthBarX + healthBarWidth * self.health, healthBarY + healthBarHeight, healthBarColor)
			end

			for part in all(self.particles) do
				-- break
				part:draw()
			end
			-- assert(#self.particles == 1)

            -- spr(4, self.pos.x-8, self.pos.y-16, 2,2 )
        end
    }
    return launcher
end


function makeIceCream(pos, vel)
    local iceCream = {
        pos = pos,
        vel = vel,
        update = function(self)
            self.pos = self.pos + self.vel * gs.dt
			local diff = self.pos - gs.player.pos
			if abs(diff.x) + abs(diff.y) < 20 then
				local len = sqrt(diff.x^2 + diff.y^2)
				-- if len < 14 and (debug and btn(dirs.x)) then
				if len < 14 then
					-- gs.player.isHit = true
					gs.isGameOver = true
					gs.gameOverState = 'lose'
				end
			end
        end,
        draw = function(self, scale)
			-- scale = 0.8
			scale = scale or 1
            sspr(gs.level.sprite.x,gs.level.sprite.y, 16, 16, self.pos.x-8*scale, self.pos.y-8*scale, 16*scale, 16*scale)
			if (debug)circ(self.pos.x, self.pos.y, 8,8)
        end
    }
    return iceCream
end

function makePlayer(pos)
    local player = {
        pos = pos,
		isMouse = true,
		oldMouse = nil,
        update = function(self)
			local dir = vec2(tonum(btn(dirs.right)) - tonum(btn(dirs.left)), tonum(btn(dirs.down)) - tonum(btn(dirs.up)))
			if dir.x!=0 or dir.y!=0 then
				self.isMouse = false
			end
			local newMouse = vec2(stat(32), stat(33))
			if self.isMouse then
            	self.pos = newMouse
			else
				if dir.x == 0 and dir.y == 0 then
					if newMouse != oldMouse then
						self.isMouse = true
					end
				end
				self.pos += dir:norm() * 50 * gs.dt
			end
			oldMouse = newMouse
			self.pos.x = mid(8, self.pos.x, 121)
			self.pos.y = mid(8*4, self.pos.y, 120)
        end,
        draw = function(self)
            spr(6, self.pos.x-8, self.pos.y-8, 2, 2)
			if (debug)circ(self.pos.x, self.pos.y, 8,8)
			local anyfixing = false
			for launch in all(gs.launchers) do
				if launch.isfixing then
					anyfixing = true
				end
			end
			if anyfixing then
				spr(13, self.pos.x-8, self.pos.y-8, 2, 2)
			end
        end
    }
    return player
end

function makeLevel(level)
	if level == 1 then
		return {
			spawnRate = 0.3,
			speed = 30,
			duration = 33,
			sprite={x=6*8, y=2*8}
			-- 6*8,2*8
		}
	elseif level == 2 then
		return {
			spawnRate = 0.4,
			speed = 30*1.25,
			duration = 33,
			sprite={x=0*8, y=2*8}
		}
	elseif level == 3 then
		return {
			spawnRate = 0.5,
			speed = 30*1.5,
			duration = 33,
			sprite={x=2*8, y=2*8}
		}
	else
		return {
			spawnRate = 0.55,
			speed = 30*1.75,
			duration = 1000,
			sprite={x=4*8, y=0*8}
		}
	end
end

function levelUp(self, skiptext)
	gs.currentLevel += 1

	gs.level = makeLevel(gs.currentLevel)
	gs.launchers = {}
	gs.levelStartTime = time()
	for i = 1,8 do
		add(gs.launchers, makeLauncher(
			vec2(i*16 - 8, 18)
		))
	end
	gs.projectiles = {}
	if skiptext then
		gs.currentAnimation = cocreate(function()
		end)
	end
	if not skiptext then
		if gs.currentLevel == 1 then
			gs.currentAnimation = cocreate(function()
				yield()
				while not btnp(dirs.x) do
					yield()
					color(7)
					print('\^w\^tday 1')
					print('')
					print('welcome!')
					print('')
					print('thank you for coming on short')
					print('notice. our last tech got a')
					print('bad case of brain freeze.')
					print('')
					print('the job is simple. the cone')
					print('portals have a direct link to')
					print('the ice cream dimension. if')
					print('one breaks down, all you have')
					print('to do is run up to it and fix')
					print('it.')
					print('')
					print("just don't get hit by any of the")
					print('ice cream. we don\'t want any')
					print('more accidents.')
				end
				gs.levelStartTime = time()

			end)
		elseif gs.currentLevel == 2 then
			gs.currentAnimation = cocreate(function()
				yield()
				while not btnp(dirs.x) do
					yield()
					color(7)
					print('\^w\^tday 2')
					print('')
					print('great work yesterday!')
					print('')
					print('today we calibrated the machines')
					print('to pull from a pocket dimension')
					print('filled with strawberry.')
					print('')
					print('the dimension has some low-grade')
					print('temporal dilation, so it will')
					print('come at you a little faster.')
					print('')
					print('just do what you did yesterday')
					print('and you\'ll be fine.')
				end
				gs.levelStartTime = time()

			end)
		elseif gs.currentLevel == 3 then
			gs.currentAnimation = cocreate(function()
				yield()
				while not btnp(dirs.x) do
					yield()
					color(7)
					print('\^w\^tday 3')
					print('')
					print('good news!')
					print('')
					print('this morning we detected a')
					print('quantum anomaly near the local')
					print('phase nexus. that can only')
					print('mean one thing...chocolate!')
					print('')
					print('better hop to it!')
				end

				gs.levelStartTime = time()

			end)
		elseif gs.currentLevel == 4 then
			gs.currentAnimation = cocreate(function()
				yield()
				while not btnp(dirs.x) do
					yield()
					color(7)
					print('\^w\^tday 4')
					print('')
					print('this is the big one.')
					print('')
					print('we picked up a traces of')
					print('a harmonic singularity')
					print('just over the event horizon.')
					print('')
					print('the neapolitan model has long')
					print('been conjectured to be')
					print('incomplete...this could be')
					print('the theoretical fourth')
					print('flavor profile...')
					print('')
					print('let\'s go get rich!')
				end
				yield()
				while not btnp(dirs.x) do
					yield()
					color(7)
					print('wait...something')
					print('isn\'t right...')
					print('')
					print('the singularity is unstable.')
					print('we are way off the map. are')
					print('we even linked to the ice')
					print('cream dimension any more?')
					print('')
					print('wait - something is coming')
					print('through.')
					print('')
					print('oh no! shut it down! you')
					print('have to shut down the')
					print('portals!')
					print('')
				end

				gs.levelStartTime = time()

			end)
		elseif gs.currentLevel == 5 then
			gs.isGameOver= true
			gs.gameOverState = 'win'
		end
	end
end

function _init(currentLevel)
	poke(0x5f2d, 1)
	local skiptext = false
	if currentLevel == nil then
		currentLevel = 1
	else
		skiptext = true
	end	
	gs = {

		getElapsed = function(self)
			return time() - self.levelStartTime
		end,
		isLevelWarmup = function(self)
			local elapsed = time() - self.levelStartTime
			return elapsed <= 3
		end,
		isFreaky = function(self)
			return self.currentLevel >= 4
		end,
		anyBroken = function(self)
			for launcher in all(self.launchers) do
				if launcher.isBroken then
					return true
				end
			end
			return false
		end,
		allBroken = function(self)
			for launcher in all(self.launchers) do
				if not launcher.isBroken then
					return false
				end
			end
			return true
		end,
		levelUp = levelUp,
		currentLevel = currentLevel - 1,
		level = nil,
		levelStartTime = 0,
		shouldLevelUp = function(self)
			local elapsed = time() - self.levelStartTime
			return elapsed > self.level.duration
		end,
		-- currentLevel = 1,
		-- level = makeLevel(1),
		isGameOver = false,
		player = makePlayer(vec2(64,64)),
		projectiles = {
            -- makeIceCream(vec2(80, 0), vec2(0, 100))
        },
		dt = 1/30,
		isDrawGameOver = false,
		restartGameDelay = 0,
		shouldDelayRestart = function(self)
			if self.endTime == nil then
				return false
			end

			return time() - self.endTime <= self.restartGameDelay
		end,
		gameOverState = nil,
		startTime = time(),
		endTime = nil,
		currentAnimation = nil,
		launchers = {}
	}
	-- gs:levelUp()
	gs:levelUp(skiptext)

	-- gs.launchers[1]:breakIt()

	-- gs:levelUp()

end

function rndrange(_min, _max)
	local diff = _max - _min
	return _min + diff * rnd()
end

metaTable = {
	__add = function(v1, v2)
		return vec2(v1.x + v2.x, v1.y + v2.y)
	end,
	__sub = function(v1, v2)
		return vec2(v1.x - v2.x, v1.y - v2.y)
	end,
	__mul = function(s, v)
		if type(s) == 'table' then
			s,v = v,s
		end

		return vec2(s * v.x, s * v.y)
	end,
	__div = function(v, s)
		return vec2(v.x / s, v.y / s)
	end,
	__eq = function(v1, v2)
		return v1.x == v2.x and v1.y == v2.y
	end
}

function vec2fromAngle(ang)
	return vec2(cos(ang), sin(ang))
end

function vecFromDir(dir)
	if dir == dirs.left then
		return vec2(-1, 0)
	elseif dir == dirs.right then
		return vec2(1, 0)
	elseif dir == dirs.up then
		return vec2(0, -1)
	elseif dir == dirs.down then
		return vec2(0, 1)
	else
		assert(false)
	end
end

function modInc(x, mod)
	return (x + 1) % mod
end

function modDec(x, mod)
	return (x - 1) % mod
end

function vec2(x, y)
	local ret = {
		x = x,
		y = y,
		norm = function(self)
			if self.x == 0 and self.y == 0 then
				return self
			end
			return vec2fromAngle(atan2(self.x, self.y))
		end,
		squareDist = function(self, other)
			return max(abs(self.x - other.x), abs(self.y - other.y))
		end,
		taxiDist = function(self, other)
			return abs(self.x - other.x) + abs(self.y - other.y)
		end,
		-- Beware of using this on vectors that are more than 128 away
		eucDist = function(self, other)
			local dx = self.x - other.x
			local dy = self.y - other.y
			-- return sqrt(dx * dx + dy * dy)
			return approx_magnitude(dx, dy)
		end,
		isWithin = function(self, other, value)
			return self:taxiDist(other) <= value and
				self:eucDist(other) <= value
		end,
		isOnScreen = function(self, extra)
			if extra == nil then extra = 0 end

			return extra <= self.x and self.x <= 128 - extra
				and extra <= self.y and self.y <= 128 - extra
		end,
		length = function(self)
			return self:eucDist(vec2(0, 0))
		end,
		angle = function(self)
			return atan2(self.x, self.y)
		end
	}

	setmetatable(ret, metaTable)

	return ret
end


function hasAnimation()

	local ret = gs.currentAnimation != nil and costatus(gs.currentAnimation) != 'dead'
	if not gs.firstdetected and ret then
		gs.firstdetected = true
		music(-1, 1000)
	end
	if not ret then
		gs.firstdetected = false
	end
	if ret then
		gs.lastdetected = false
	end
	if not gs.lastdetected and not ret then
		gs.lastdetected = true
		if gs.currentLevel < 4 then
			music(56, 3000)
		else
			music(13, 3000)
		end
	end
	return ret
end

function acceptInput()

end

function _update60()
	if gs.isGameOver then
		if gs.endTime == nil then
			gs.endTime = t()
		end
		-- Restart
		if not gs:shouldDelayRestart() then
			if btnp(dirs.x) then
				if gs.gameOverState == gameOverWin then
					_init()
				else
					_init(gs.currentLevel)
				end
			end
		end
		return
	end

	if hasAnimation() then
		-- local active, exception = coresume(gs.currentAnimation)
		-- if exception then
		-- 	stop(trace(gs.currentAnimation, exception))
		-- end

		return
	end

	acceptInput()

	gs.player:update()
	if not gs:isLevelWarmup() then
		for launcher in all(gs.launchers) do
			launcher:update()
		end
	end
	for proj in all(gs.projectiles) do
		proj:update()
	end

	if gs:shouldLevelUp() and not gs:anyBroken() then
		gs:levelUp()
	end

	if gs:isFreaky() and gs:allBroken() then
		-- gs.isGameOver = true
		-- gs.gameOverState = 'win'
		gs:levelUp()
	end
	
	if debug and btnp(dirs.z) then
		gs:levelUp()
	end

end

function drawGameOverWin()
	music(-1,500)
	-- music(56,1000)
	color(8)
	print(' it has been 0 days since')
	print(' last transdimensional rift')
	color(7)
	print('')
	print(' but thank you for saving')
	print(' the factory!')
	print('')
	print('\n press ❎ to play from beginning')

	-- print('you saved the factory!')
end

function drawGameOverLose()
	color(7)
	if not gs:shouldDelayRestart() then
		music(-1, 1000)
		color(8)
		print(' it has been 0 days since')
		print(' last accident')

		color(7)
		print('\n press ❎ to play day ' .. gs.currentLevel .. ' again')
	end
end

function _draw()
	cls(0)

	if gs.isGameOver then
		if gs.isDrawGameOver then
			if gs.gameOverState == gameOverWin then
				drawGameOverWin()
			else
				drawGameOverLose()
			end
			return
		else
			gs.isDrawGameOver = true
		end
	end

	if hasAnimation() then
		local active, exception = coresume(gs.currentAnimation)
		if exception then
			stop(trace(gs.currentAnimation, exception))
		end

		-- print('❎', 90, 120, 7)
		print('❎', 115, 115,7)

		return
	end

	map(0, 0, 0, 0, 16, 16)
	gs.player:draw()
	for launcher in all(gs.launchers) do
		launcher:draw()
	end
	for proj in all(gs.projectiles) do
		proj:draw()
	end

	if debug then
		print(time()-gs.levelStartTime, 7)
	end
	
	if gs:isLevelWarmup() then
		color(7)
		local timeval = 3-gs:getElapsed()\1
		if timeval > 0 then
			print('\^w\^t' .. tostr(timeval), 64, 64, 7)
		end
	end	
	-- Draw
end
__gfx__
0000000000ffff0000002222222220000000000000000000000000000000000000000000dddddddddddddddd1111111111111111000000000000000000000000
000000000f7ffff00022bbbbbbbbb2200000007777700000000000000000000000000000dddddddddddddddd1111111111111111000000000000000000000000
00700700f7ffff7f004bbbbbbbbbbb400000777877777000000000099000000000000000dddddddddddddddd1111111111111111000000000006600000000000
00077000fffffff70044bbbbbbbbb4400007777877777800000000a999a9000000000000dddddddddddddddd1111111111111111000000000066000000000000
00077000ffffffff004f444444444f40007787778777877000004aaaaaaa900000000000dddddddddddddddd1111111111111111000000000066006000000000
00700700ffffffff004fffffffffff400078777ccc77777000049aaaaaaaa90000000000dddddddddddddddd1111111111111111000000000676666000000000
000000000ffffff0004fffffffffff40077787ccccc7777700099aaaaaaa990000000000dddddddddddddddd1111111111111111000000006765660000000000
0000000000ffff00000444444444440007777cc555cc87780049aaaaaaaaaaa000000000dddddddddddddddd1111111111111111000000067656000000000000
00000000000000000004fffffffff40007777cc555cc788700499999999999a000000000dddddddddddddddd1111111111111111000000676560000000000000
00000000000000000004fffffffff40007777cc555cc7777000988718718800000000000dddddddddddddddd1111111111111111000006765600000000000000
00000000000000000004fffffffff400077777ccccc77777000088718718800000000000dddddddddddddddd1111111111111111000067656000000000000000
000000000000000000004f4f4f4f40000077877ccc787770000088778778800000000000dddddddddddddddd1111111111111111006676560000000000000000
0000000000000000000044f4f4f440000077787777787770000088888888800000000000dddddddddddddddd1111111111111111066665600000000000000000
000000000000000000004f4f4f4f40000007877777877700000008888888000000000000dddddddddddddddd1111111111111111060066000000000000000000
000000000000000000004fffffff40000000777777777000000000000000000000000000dddddddddddddddd1111111111111111000066000000000000000000
000000000000000000000444444400000000007777700000000000000000000000000000dddddddddddddddd1111111111111111000660000000000000000000
0000000000000000000000000000000000002222222220000000000000000000000000001111111111111111dddddddddddddddd000000000000000000000000
000000eeeee00000000000444440000000225555555552200000007777700000000000001111111111111111dddddddddddddddd000000000000000000000000
0000eeeeeeeee000000044444444400000455555555555400000777777777000000000001111111111111111dddddddddddddddd000000000000000000000000
000eeeeeeeeeee00000444444444440000445555555554400007777777777700000000001111111111111111dddddddddddddddd000000000000000000000000
00eee777eeeeeee00044499944444440004f444444444f4000777fff77777770000000001111111111111111dddddddddddddddd000000000000000000000000
00ee77eeeeeeeee00044994444444440004fffffffffff400077ff7777777770000000001111111111111111dddddddddddddddd000000000000000000000000
0eee7eeeeeeeeeee0444944444444444004fffffffffff400777f77777777777000000001111111111111111dddddddddddddddd000000000000000000000000
0eee7eeeeeeeeeee044494444444444400044444444444000777f77777777777000000001111111111111111dddddddddddddddd000000000000000000000000
0eeeeeeeeeeeeeee04444444444444440004fffffffff4000777777777777777000000001111111111111111dddddddddddddddd000000000000000000000000
0eeeeeeeeeeeeeee04444444444444440004fffffffff4000777777777777777000000001111111111111111dddddddddddddddd000000000000000000006765
0eeeeeeeeeeeeeee04444444444444440004fffffffff4000777777777777777000000001111111111111111dddddddddddddddd000000000000000000667656
00eeeeeeeeeee2e0004444444444424000004f4f4f4f40000077777777777670000000001111111111111111dddddddddddddddd000000000000000006666560
00e22eeeeeee2ee00042244444442440000044f4f4f440000076677777776770000000001111111111111111dddddddddddddddd000000000000000006006600
000e22222222ee00000422222222440000004f4f4f4f40000007666666667700000000001111111111111111dddddddddddddddd000000000000000000006600
0eeeeeeeeeeeeeee044444444444444400004fffffff40000777777777777777000000001111111111111111dddddddddddddddd000000000000000000066000
00eee0eeeee0eee0004440444440444000000444444400000077707777707770000000001111111111111111dddddddddddddddd000000000000000000000000
__label__
d000000000000000111111111111111100000000ddd000dd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd0000010000000001
d000000000dd000d111111111111111100000000dddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd0000010000000001
d0000000000ddddd1111111111111111d0000000dddddddd1111117711111111dddddddddddddddd1111111111111111dddddddddddddddd1000011000000001
d0000000000ddddd1111117711111111d00000000000dddd1111777777111111ddddddd77ddddddd1111111111111111dddddd77dddddddd1000001100000001
dd000000000ddddd1111177771111111d000000000000ddd11117f7777711111ddddd77777dddddd1111111711111111ddddd7777ddddddd1000000000000011
ddd0000000dddddd1111777777111111dd00000000000ddd1117777777777111ddddd7f7777ddddd1111117f77111111dddd777777dddddd1000000000000111
dd0000000ddddddd1111777777111111dd00000000000ddd1117777777777711dddd7777777ddddd111117f777111111dddd777777dddddd1100000000000111
dd000000dddddddd1111177777111111dd0000000000dddd11777fff77777771dddd7777777ddddd1111117777111111ddddd77777dddddd1100000000000111
dd000000dddddddd1111777777111111dd00000000dddddd1177ff7777777771ddddd677767ddddd1111177777111111dddd777777dddddd1110000000001111
ddd00000d0dddddd1111111111111111ddd000000d0ddddd1777f77777777777dddd7777777ddddd1111111111111111dddddddddddddddd1111000000001111
dddd000000022ddd1111222222222111dddd222200002ddd1777f77777777777dddd222222222ddd1111222222222111dddd222222222ddd1111202020002111
dd2255055000522d1122555555555221dd2255500005522d1777777777777777dd2255555555522d1122555555555221dd2255555555522d1122000550055221
dd4550005505554d1145555555555541dd4555050005554d1777777777777777dd4555555555554d1145555555555541dd4555555555554d1145505500005541
dd4400055555544d1144555555555441dd4450005055544d1777777777777777dd4455555555544d1144555555555441dd4455555555544d1144555550055441
dd4f404444444f4d114f444444444f41dd4f400004444f4d1177777777777671dd4f444444444f4d114f444444444f41dd4f444444444f4d114f440044444f41
dd4fffffffffff4d114fffffffffff41dd4fff00ffffff4d1176677777776771dd4fffffffffff4d114fffffffffff41dd4fffffffffff4d114ff0000fffff41
114ffff0ffffff41dd4fffffffffff4d114ff000ffffff41dd4766666666774d114fffffffffff41dd4fffffffffff4d114fff77777fff41dd4fff00ffffff4d
1114440004444411ddd44444444444dd1114440444444411d7777777777777771114444444444411ddd44444444444dd1114777777777411ddd44000444444dd
1114fff0fffff411ddd4fffffffff4dd1114fffffffff411dd777f77777f777d1114fffffffff411ddd4fffffffff4dd1117777777777711ddd4ff0ffffff4dd
1114fffffffff411ddd4fffffffff4dd1114fffffffff411ddd4fffffffff4dd1114fffffffff411ddd4fffffffff4dd11777fff77777771ddd4fffffffff4dd
1114fffffffff411ddd4fffffffff4dd1114fffffffff411ddd4fffffffff4dd1114fffffffff411ddd4fffffffff4dd1177ff7777777771ddd4fffffffff4dd
11114f4f4f4f4111dddd4f4f4f4f4ddd11114f4f4f4f4111dddd4f4f4f4f4ddd11114f4f4f4f4111dddd4f4f4f4f4ddd1777f77777777777dddd4f4f4f4f4ddd
111144f4f4f44111dddd44f4f4f44ddd111144f4f4f44111dddd44f4f4f44ddd111144f4f4f44111dddd44f4f4f44ddd1777f77777777777dddd44f4f4f44ddd
11114f4f4f4f4111dddd4f4f4f4f4ddd11114f4f4f4f4111dddd4f4f4f4f4ddd11114f4f4f4f4111dddd4f4f4f4f4ddd1777777777777777dddd4f4f4f4f4ddd
11114fffffff4111dddd4fffffff4ddd11114fffffff4111dddd4fffffff4ddd11114fffffff4111dddd4fffffff4ddd1777777777777777dddd4fffffff4ddd
1111144444441111ddddd4444444dddd1111144444441111ddddd4444444dddd1111144444441111ddddd4444444dddd1777777777777777ddddd4444444dddd
1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1177777777777671dddddddddddddddd
1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1176677777776771dddddddddddddddd
1180000000000001dddddddddddddddd1180000000000001dddddddddddddddd1111111111111111dddddddddddddddd1117666666667711dd8000000000000d
1180000000000001dddddddddddddddd1180000000000001dddddddddddddddd1111111111111111dddddddddddddddd1777777777777777dd8000000000000d
1180000000000001dddddddddddddddd1180000000000001dddddddddddddddd1111111111111111dddddddddddddddd1177717777717771dd8000000000000d
1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd
dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111
dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111
dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111
dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111
dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111
dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111
dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111
dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111
dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111
dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111
dddddddddddddddd1111117777711111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111
dddddddddddddddd1111777777777111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111
dddddddddddddddd1117777777777711dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111
dddddddddddddddd11777fff77777771dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111
dddddddddddddddd1177ff7777777771dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111
dddddddddddddddd1777f77777777777dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111
1111111111111111d777f777777777771111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd
1111111111111111d7777777777777771111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd
1111111111111111d7777777777777771111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd
1111111111111111d7777777777777771111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd
1111111111111111dd7777777777767d1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd
1111111111111111dd7667777777677d1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd
1111111111111111ddd76666666677dd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd
1111111111111111d7777777777777771111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd
1111111111111111dd777d77777d777d1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd
1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd
1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd
1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd
1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd
1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd
1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd
1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd
dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111
dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111
dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111
dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111
dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111
dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111
dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111
dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111
dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111
dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddd77777ddddd1111111111111111dddddddddddddddd1111111111111111
dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddd777777777ddd1111117777711111dddddddddddddddd1111111111111111
dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111ddd77777777777dd1111777777777111dddddddddddddddd1111111111111111
dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dd777fff7777777d1117777777777711dddddddddddddddd1111111111111111
dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dd77ff777777777d11777fff77777771dddddddddddddddd1111111111111111
dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111d777f777777777771177ff7777777771dddddddddddddddd1111111111111111
dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111d777f777777777771777f77777777777dddddddddddddddd1111111111111111
1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1777777777777777d777f777777777771111111111111111dddddddddddddddd
1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1777777777777777d7777777777777771111111111111111dddddddddddddddd
1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1777777777777777d7777777777777771111111111111111dddddddddddddddd
1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1177777777777671d7777777777777771111111111111111dddddddddddddddd
1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1176677777776771dd7777777777767d1111111111111111dddddddddddddddd
1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1117666666667711dd7667777777677d1111111111111111dddddddddddddddd
1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1777777777777777ddd76666666677dd1111111111111111dddddddddddddddd
1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1177717777717771d7777777777777771111111111111111dddddddddddddddd
1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dd777d77777d777d1111111111111111dddddddddddddddd
1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd
1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd
1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd
1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd
1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd
1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd
1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd
dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111
dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111
dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111
dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111
dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111
dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111
dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111
dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111
dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111
dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111
dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111
dddddddddddddddd1111111111111111ddddddddddd99ddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111
dddddddddddddddd1111111111111111dddddddddda999a91111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111
dddddddddddddddd1111111111111111dddddddd4aaaaaaa9111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111
dddddddddddddddd1111111111111111ddddddd49aaaaaaaa911111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111
dddddddddddddddd1111111111111111ddddddd99aaaaaaa9911111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111
1111111111111111dddddddddddddddd11111149aaaaaaaaaaaddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd
1111111111111111dddddddddddddddd111111499999999999addddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd
1111111111111111dddddddddddddddd11111119887187188ddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd
1111111111111111dddddddddddddddd11111111887187188ddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd
1111111111111111dddddddddddddddd11111111887787788ddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd
1111111111111111dddddddddddddddd11111111888888888ddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd
1111111111111111dddddddddddddddd1111111118888888dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd
1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd
1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd
1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd
1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd
1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd
1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd
1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd
1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd
1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd1111111111111111dddddddddddddddd

__map__
090a0b0c090a0b0c090a0b0c090a0b0c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
191a1b1c191a1b1c191a1b1c191a1b1c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
292a2b2c292a2b2c292a2b2c292a2b2c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
393a3b3c393a3b3c393a3b3c393a3b3c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
090a0b0c090a0b0c090a0b0c090a0b0c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
191a1b1c191a1b1c191a1b1c191a1b1c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
292a2b2c292a2b2c292a2b2c292a2b2c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
393a3b3c393a3b3c393a3b3c393a3b3c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
090a0b0c090a0b0c090a0b0c090a0b0c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
191a1b1c191a1b1c191a1b1c191a1b1c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
292a2b2c292a2b2c292a2b2c292a2b2c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
393a3b3c393a3b3c393a3b3c393a3b3c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
090a0b0c090a0b0c090a0b0c090a0b0c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
191a1b1c191a1b1c191a1b1c191a1b1c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
292a2b2c292a2b2c292a2b2c292a2b2c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
393a3b3c393a3b3c393a3b3c393a3b3c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
013d00200a6100f611156111c6112c6113161131611236111b6110d6110d6110c6110b6110a621096110861107611096110b6110161106611076110f611186111c61125611256111c61116611126110d61109611
0108080a1307014070180701806018050180401803018020180141801500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010b0809245701d5701c5701c5601c5501c5401c5301c5201c5100050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
010200280c31500000000000000000000000000f2250000000000000000c3000c415000000000000000000000c3000000000000000000c30000000000000741500000000000c2150000000000000000c30000000
010300280000000000246250000000000000000000000000246150000000000000000c30018625000000000018000180002430018000180001800024300180001800018000000000000000000000000000000000
011000010017000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01090004180701a07015070160700c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c000000000000000000000000000000000
0109000418070160701307011070295052650529505265052d505295052950526505225051f5051d505215052e5052b50528505245052d5052d5052850528505265052e5052b5052850524505215051d50521505
0114000020734200351c7341c0351973419535157343952520734200351c7341c0351953219035147341503121734210351c7341c0261973419035237341703521734395251c7341c03519734195351773717035
011400000c043090552072409055246151972315555090550c053090651972309565207242461509065155650c053060652072406065246151672306065125650c05306065167230656520724246150606515555
011400000c053021651e7240206524615197450e7650c05302165020651e7341e7350256524615020650e56501165010651e7240c05324615167230b0450d0650c05301165197440b56520724246150106515555
0114000020724200251c7241c02525742287421572439525207242a7422c7412c7322c72219025147242a74228742287451c7341e7421e7421e735237241702521724395251c7341c03519734195351773617035
0014000020724200251c7241c02525742287421572439525207242a7422c7412c7322c72219025147242f7422d7422d7452d734217422174221735237241702521724395251c7341c03519734195351773617035
0116002006055061550d055061550d547061550d055061550d055060550615501155065470d15504055041550b055041550b547041550b055041550b0550b155040550b155045460b1550b055041550b0550b155
010b00201e4421e4321f4261e4261c4321c4221e4421e4321e4221e4221f4261e4261c4421c4321c4221c4221c4221c4221c4221c4221c4221c4221c4221c4221c4221c4221c4221c42510125101051012510105
011600001e4401e4321e4221e4250653500505065351a0241a025065351a0250653500505065351902419025045351702404535005050453500505045351e0241e025045351e0240453504535005050453504535
010b00201e4421e4361f4261e4261c4421c4421a4451c4451e4451f44521445234452644528445254422543219442194322544225432264362543623442234322144221432234472343625440234402144520445
01160000190241902506535135000653500505065351a0241a025065351a0250653506404065351902419025045351702404535005050453500505045351e0241e025045351e0240453504535005050453504535
010e000005455054553f52511435111250f4350c43511125034550345511125182551b255182551d2551112501455014552025511125111252025511125202550345520255224552325522455202461d4551b255
010e00000c0530c4451112518455306251425511255054450c0530a4353f52513435306251343518435054450c053111251b4353f525306251b4353f5251b4350c0331b4451d2451e445306251d2451844516245
010e00000145520255224552325522445202551d45503455034050345503455182551b455182551d455111250045520255224552325522455202461d4551b255014550145511125182551b455182551d45511125
010e00000c0531b4451d2451e445306251d245184450c05317200131253f52513435306251343518435014450c0431b4451d2451e445306251d245184451624511125111253f5251343530625134351843500455
010e0000004550045520455111251d125204551d1252912501455014552c455111251d1252c4551d12529125034552c2552e4552f2552e4552c2552945503455044552c2552e4552f2552e4552c246294551b221
010e00000c0530c0531b4551b225306251b4551b2250f4250c0530c05327455272253062527455272251b4250c0531b4451d2451e445306251d245184450c0530c0531b4451d2451e445306251d2451844500455
010d00000c0530445504255134453f6150445513245044550c0531344513245044553f6150445513245134450c0530445504255134453f6150445513245044550c0531344513245044553f615044551324513445
010d000028555234452d2352b5552a4452b2352f55532245395303725536540374353b2503954537430342553654034235325552f2402d5352b2502a4452b530284552624623530214551f24023535284302a245
010d00002b5552a4452823523555214451f2351e5551c4452b235235552a445232352d5552b4452a2352b555284452a235285552644523235215551f4451c2351a555174451e2351a5551c4451e2351f55523235
010d00000c0530045500255104453f6150045510245004550c0530044500245104553f6150045510245104450c0530045500255104453f6150045510245004550c0531044510245004553f615004551024500455
010d00000c0530245502255124453f6150245512245024550c0531244512245024553f6150245502255124450c0530245502255124453f6150245512245024550c0530244512245024553f615124550224512445
010d00002b5552a45528255235552b5452a44528545235452b5352a03528535235352b0352a03528735237352b0352a03528735237351f7251e7251c725177251f7151e7151c715177151371512715107150b715
010c00200c0530c235004303a324004453c3253c3240c0533c6150c0530044000440002353e5253e5250c1530c0530f244034451b323034453702437522370253c6153e5250334003440032351b3230c0531b323
010c00200c05312235064303a324064453c3253c3240c0533c6150c0530644006440062353e5253e5250c1530c05311244054451b323054453a0242e5223a0253c6153e52503345054451323605436033451b323
010c00202202524225244202432422425243252432422325223252402522420242242222524425245252422522325222242442524326224252402424522220252452524524223252442522227244262432522325
010c0000224002b4202e42030420304203042033420304203042030222294202b2202e420302202b420272202a4202a4222a42227420274202742025421274212742027420274202722027422272222742227222
010c00002a4202a4222a422274202742027422272222742527400254202a2202e4202b2202a426252202a4202742027422274222442024222244222242124421244202442024420244202422024422182210c421
011100000c3430035500345003353c6150a3300a4320a3320c3430335503345033353c6151333013432133320c3430735507345073353c6151633016432163320c3430335503345033353c6151b3301b4321b332
01110000162251b425222253751227425375122b5112e2251b4352b2402944027240224471f440244422443224422244253a512222253a523274252e2253a425162351b4352e4302e23222431222302243222232
011100000c3430535505345053353c6150f3301f4260f3320c3430335503345033353c6151332616325133320c3430735507345073353c6151633026426163320c3430335503345033353c6150f3261b3150f322
011100001d22522425272253f51227425375122b5112e225322403323133222304403043030422375112e44237442372322c2412c2322c2222c4202c4153a425162351b4352b4402b4322b220224402243222222
011100001f2401f4301f2201f21527425375122b5112e225162251b5112e2253a5122b425375122b5112e225162251b425225133021033410375223341027221162251b425222253751227425373112b3112e325
01110000182251f511242233c5122b425335122b5112e225162251b5112e2253a5122b425375122b5112e225162251b425225133021033410375223341027221162251b425222253751227425373112b3112e325
011100000f22522425272253f51227425375122b5112e2252724027232272222444024430244222b511224422b4422b23220241202322023220420204153a425162351b4351f4401f4321f2201d4401d4321d222
007800000c8410c8410c8400c8400c8400c8400c8400c8400c8400c8400c8400c8400c8400c8400c8400c84018841188401884018840188401884018840188402483124830248302483024830248302483024830
01780000269542694026930185351870007525075240752507534000002495424940249301d5241d7000c5250c5242952500000000002b525000001d5241d5250a5440a5450a5440a5201a7341a7350a0350a024
017800000072400735007440075500744007350072400715007340072500000057440575505744057350572405735057440575503744037350372403735037440375503744037350372403735037440373503704
017800000a0041f734219442194224a5424a5224a45265351a5341a5350000026934269421ba541ba501ba550c5340c5450c5540c555000001f9541f9501f955225251f5341f52522a2022a3222a452b7342b725
0110002005b4008b3009b200ab3009b4008b3006b2002b3001b4006b3006b2003b3002b4003b3005b2007b3008b4009b300ab200ab300ab4009b3008b2007b3005b4003b3002b2002b3002b4002b3004b2007b30
0118042000c260cc260cc2600c2600c2600c260cc260cc260cc2600c2600c260cc260cc260cc2600c2600c260cc2600c2600c2600c260cc260cc260cc2600c260cc2600c260cc260cc2600c260cc260cc2605c26
012000200cb200fb3010b4011b5010b400fb300db2009b3008b400db500db400ab3009b200ab300cb400eb500fb4010b3011b2011b3011b4010b500fb400eb300cb200ab3015b4015b5015b4015b300bb200eb30
012c002000000000000000000000000000000000000000001372413720137201372015724157201572015722137241872418720187201872018720187201872018725187021a7241c7211c7201c7201c7201c720
012800001c7201f7241f7201f7201f7201f720157241572015720157201572015720157201572215725000001c7241c7201c7201c7201c7201f7241f7201f7201f7201f722157241572015720157201572015720
012800001572015725000001f7241c7241c7201c7201c7201c7201c72215724137211372013720137201372013720137221872418720187201872018720187201872018720187201872218725187001870018705
012000000dd650dd550dd450dd351075510745107351072500c5517d5517d4517d3517d2517d2510755107450dd650dd550dd450dd351075510745107351072500c5417d5517d4517d3517d2517d250dd250dd35
011d0c201072519d5519d4519d3519d251005510045100351002517d550f7350f7350f7250f72510725107251072519d3519d3519d2519d250b0250b0350b7350b0250b7250b72517d3517d350f7350f7350f725
0120000012d6512d5512d4512d351575515745157351572500c5510d5510d4510d3510d2510d25157551574512d6512d5512d4512d35157551574500c54157351572519d5519d4519d3519d2519d250dd250dd35
011d0c20107251ed351ed351ed351ed251503515035150251502517d35147351472514725147251572515725157251ed351ed351ed251ed2515025150351573515025157251572519d3519d350f7350f7350f725
0120000019d5519d450dd3501d551405014040147321472223d3523d450bd350bd551505015040157321572219d5519d450dd3501d551705019040197321972223d3523d450bd350bd551c0501e0401e7321e722
012000001ed551ed4512d3506d552105021040217322172228d4528d3528d2520050200521e0401e7321e7221ed551ed4512d3506d552105021040257322572228d5528d4528d3528d251c0401e0301e7221e722
0112000024e4524e3521f251ff351ff451de3524f2524f3518e451de351fe251d73018e251de351fe451d7321ff4521f3524f252973029e252be352ee4524e3524e2524e3521f451ff351ff251de352473224f35
0112000024e2524e35219451ff352192524e3524e4524f3526f2526f351fe451d73232f4532f352be25297322bf252bf352df253573235e2537e353ae4530e3530e2530e352df452bf352bf2529e253073230f35
011200002de252de352af4528f3528f2526e352df452df3521e2526e3528e452673221e3526e2528e352673228f252af352df253273232e3534e2537e352de252de352de252af3528f2528f3526e252d7322df35
011200000a0550a0350a0250a0550a0350a0250a0550a0350a0250a0550a035050250a0550a0350a0250a0550a035050250a0550a0350a0250a0550a035050250a0550a035050250a0550a035050250a0550a035
011200000505505035050250505505035050250505505035050250505505035000250505505035050250505505035000250505505035050250505505035000250505505035000250505505035000250505505035
011200000705507035070250705507035070250705507035070250705507035020250705507035070250705502035020550205502035020250205502035090250205502035090250205502035090250205502035
__music__
00 08094344
00 080a4344
00 0b094344
00 0c0a4344
00 0b094344
02 0c0a4344
01 12134344
00 12134344
00 12134344
00 12134344
00 14154344
00 14154344
02 16174344
01 18424344
00 1b424344
00 1c424344
00 18424344
00 181a4344
00 1b1a4344
00 1c194344
02 181d4344
00 1e424344
00 1f424344
01 1e204344
00 1f204344
00 1e204344
00 1f204344
00 1e214344
00 1f224344
00 1e214344
02 1f224344
00 23424344
00 23424344
01 23244344
00 23244344
00 25294344
00 25264344
00 23274344
02 23284344
03 2a2b2c2d
01 2e2f3031
00 2e2f3032
02 2e2f3033
01 34354344
00 34354344
00 36374344
00 34384344
00 34384344
02 36394344
00 0d117f44
01 0d117f44
00 0d0e7f44
00 0d0e7f44
00 0d107f44
00 0d107f44
02 0d0f7f44
01 3d3a4344
00 3e3a4344
00 3d3b4344
00 3e3a4344
00 3f3c5344
02 3f3c5344
00 7e7f5344
00 7e7f5344

__meta:cart_info_start__
cart_type: game
# Embed: 750 x 680
game_name: Dimensional Delights
# Leave blank to use game-name
game_slug: 
jam_info:
  - jam_name: TriJam
    jam_number: 278
    jam_url: null
    jam_theme: 'The great unknown'
  - jam_name: Summer Game Jam
    jam_number: 2024
    jam_url: null
    jam_theme: '0 Days since Last Accident'
tagline: Explore the great unknown of the ice cream dimension!
time_left: '0:0:0'
develop_time: '5 hours'
description: |
  Maintain the ice cream portals so you can explore the depths of the ice cream dimension! Don't delve too greedily though...the unknown is not always great
controls:
  - inputs: [MOUSE, ARROW_KEYS]
    desc: Move player
hints: ''
acknowledgements: |
    Inspired by the Neopets game [Ice Cream Machine](https://www.neopets.com/games/game.phtml?game_id=507)

    Music is from [Gruber](https://www.lexaloffle.com/bbs/?uid=11292)'s [Pico-8 Tunes Vol. 2](https://www.lexaloffle.com/bbs/?tid=33675), Track 2 - Need for Speed, Track 10 - Dimensional Gate  
    Licensed under [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/)
to_do: []
version: 0.1.0
img_alt: A creature wearing a hardhat in the midst of ice cream cones
about_extra: ''
number_players: [1]
__meta:cart_info_end__


