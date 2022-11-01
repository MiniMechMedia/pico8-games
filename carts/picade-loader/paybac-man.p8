pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
--paybac-man                     v0.2.0
--caterpillar games





gs = nil

dirs = {
	left = 0,
	right = 1,
	up = 2,
	down = 3,
	z = 4,
	x = 5
}

gameOverWin = 'win'
gameOverLose = 'lose'

function getMousePos()
	return vec2(stat(32), stat(33))
end
function mouseDidShoot()
	return btnp(dirs.x)
	-- return (stat(34) & 0x1) > 0 or btn(dirs.x) 
end

function _init(numPlayers)
	-- numPlayers = 2

	-- poke(0x5f2d, 0x1 | 0x2)
	-- TODO reset mapdata
	menuitem(1, '1 player', function()
		_init(nil)
	end)
	menuitem(2, '2 player', function()
		_init(2)
	end)
	for x = 0, 16 do
		for y = 0, 16 do
			if mget(x,y) == 0 then
				mset(x,y,7)
			end
		end
	end
	gs = {
		gameOverCountdown = nil,
		numPlayers = numPlayers,
		isMultiplayer = function(self)
			-- I suppose you could have single player multiplayer...
			return self.numPlayers != nil
		end,
		camShakeCount = 0,
		level = 1,
		isGameOver = false,
		enemiesKilled = 0,
		shotsFired = 0,
		gameOverState = nil,
		startTime = t(),
		endTime = nil,
		currentAnimation = nil,
		player = makePlayer(),
		-- enemies = makeEnemies(4),
		projectiles = {},
		dt = 1/30,
		moves = {
			vec2(0,1),
			vec2(1,0),
			vec2(-1,0),
			vec2(0,-1)
		}
	}

	if gs:isMultiplayer() then
		gs.enemies = makeEnemies(numPlayers)
	else
		gs.enemies = makeEnemies(4)
	end
	-- for enemy in all(gs.enemies) do
	-- 	enemy.isDead = true
	-- end
	gs.currentAnimation = cocreate(function()
		music(0)
		for i = 1, 30 do 
			yield()
		end
	end)

	-- gs.enemies[1].isDead = true
end

function increaseLevel()
	-- music(3)
	gs.level += 1
	gs.enemies = makeEnemies(gs.level+3)
	gs.projectiles = {}
	gs.player.tilePos = vec2(8,8)
	for x = 0, 16 do
		for y = 0, 16 do
			if mget(x,y) == 0 then
				mset(x,y,7)
			end
		end
	end
	gs.currentAnimation = cocreate(function()
		music(-1)
		music(0)
		for i = 1, 30 do 
			yield()
		end
	end)
end


function makeEnemies(count)
	local ret = {}
	corners = {
		vec2(1,1),
		vec2(14,1),
		vec2(1,14),
		vec2(14,14)
	}
	local mytryshoot = function() end
	if gs:isMultiplayer() then
		mytryshoot = tryShoot
	end
	for i = 1, count do
		local originalPos = corners[i%4+1]
		local spriteNumber = 17 + (i%4)
		local enemy = {
			enemyId = i - 1,
			health = 100,
			shells = 0,
			shootCooldown = 5,
			shootCountdown = 0,
			tryShoot = mytryshoot,
			tilePos = originalPos,
			originalPos = originalPos,
			spriteNumber = spriteNumber,
			vel = vec2(0,0),
			getCenter = function(self)
				return self.tilePos * 8 + vec2(4,4)
			end,
			getScreenPos = function(self)
				return self.tilePos * 8
			end,
			isDead = false,
			draw = function(self)
				local screenPos = self.tilePos * 8
				if self.isDead then
					spr(21, screenPos.x, screenPos.y)
				else
					spr(spriteNumber, screenPos.x, screenPos.y)
					if gs:isMultiplayer() then
						if self.vel == vec2(0,1) then
							spr(38, screenPos.x-4, screenPos.y+5)
						elseif self.vel == vec2(0,-1) or self.vel == vec2(0,0) then
							spr(36, screenPos.x+4, screenPos.y-1)
						elseif self.vel == vec2(1,0) then
							spr(37, screenPos.x+6, screenPos.y)
						elseif self.vel == vec2(-1,0) then
							spr(35, screenPos.x-6, screenPos.y)
						end

					end
				end
			end,
			update = function(self)
				if gs:isMultiplayer() then
					if btn(dirs.left, self.enemyId) then
						self.queuedMove = vec2(-1,0)
					elseif btn(dirs.right, self.enemyId) then
						self.queuedMove = vec2(1,0)
					elseif btn(dirs.up, self.enemyId) then
						self.queuedMove = vec2(0,-1)
					elseif btn(dirs.down, self.enemyId) then
						self.queuedMove = vec2(0,1)
					end	
				else	
					self.queuedMove = rnd(gs.moves)
				end
				if not self.isDead then
					moveEntity(self)
					self.shootCountdown -= 1
					self:tryShoot()
				end

				if gs:isMultiplayer() and (self.tilePos:flr() == self.tilePos) then
					if fget(mget(self.tilePos.x, self.tilePos.y), 1) then
						pickUpShell(self.tilePos, self)
						-- TODO sfx
					end
				end
				-- self.tilePos += vec2fromAngle(rnd()) / 20
				-- wrapAround(self)
				if self.health <= 0 and not self.isDead then
					self.isDead = true
					sfx(22)
					gs.enemiesKilled += 1
				end
			end
		}
		add(ret, enemy)
	end
	return ret
end

function canMoveThere(here, diff)
	local there = here + diff
	return not fget(mget(there.x, there.y), 0)
end

function getIndex(cardinal)
	if cardinal == vec2(-1,0) then
		return 1
	elseif cardinal == vec2(0,-1) then
		return 2
	elseif cardinal == vec2(1,0) then
		return 3
	else
		return 4
	end
end

function getDir(ind)
	return ({
		vec2(-1,0),
		vec2(0,-1),
		vec2(1,0),
		vec2(0,1)
	})[ind]
end

function moveEntity(self)
	if self.tilePos:flr() == self.tilePos then
		if self.queuedMove then
			if canMoveThere(self.tilePos, self.queuedMove) then
				self.vel = self.queuedMove
				if self == gs.player then
					self.orientation = getIndex(self.queuedMove)
					self.spriteNumber = 0 + self.orientation
				end
			end
			self.queuedMove = nil
		end
		if not canMoveThere(self.tilePos, self.vel) then
			self.vel = vec2(0,0)
		end
	end

	-- local newPos = self.tilePos + self.vel / 4
	-- local mgetPos = self.tilePos + self.vel

	self.tilePos += self.vel / 4

			-- self.tilePos = newPos
	wrapAround(self)
end



function makePlayer()
	return {
		enemyId=0,
		shells = 0,
		lives = 3,
		tilePos = vec2(8,8),
		orientation=1,
		spriteNumber = 1,
		vel = vec2(0,0),
		screenPos = vec2(64, 64),
		getScreenPos = function(self)
			return self.tilePos * 8
			-- return self.screenPos
		end,
		getCenter = function(self)
			return self.tilePos * 8 + vec2(4,4)
		end,
		calcTilePos = function(self)
			assert(false)
		end,
		queuedMove = nil,
		shootCooldown = 5,
		shootCountdown = 0,
		theta = 0,
		draw = function(self)
			local screenPos = self.tilePos * 8
			-- spr(self.spriteNumber, screenPos.x, screenPos.y)
			-- screenPos += getDir(self.orientation)*2
			-- spr(self.orientation + 34, screenPos.x, screenPos.y)

			-- local target = gs.player:getCenter() + gs.player.vel
			-- local projPos = gs.player:getCenter()
			-- -- TODO
			-- local ang = (target - projPos):angle()
			-- self.theta = ang

			-- local perp = vec2fromAngle(self.theta + 0.25)
			-- local lineStart = gs.player:getCenter() - perp * 4
			-- local lineEnd = lineStart + 8 * vec2fromAngle(self.theta)

			-- for i = 0, 7 do
			-- 	tline(lineEnd.x, lineEnd.y,
			-- 		lineStart.x, lineStart.y,
			-- 			16 + i/8, 0,
			-- 			0, 
			-- 			1/8)
			-- 	tline(lineEnd.x+1, lineEnd.y,
			-- 		lineStart.x+1, lineStart.y, 
			-- 			16 + i/8, 0,
			-- 			0, 
			-- 			1/8)
			-- 	lineStart += perp
			-- 	lineEnd += perp
			-- end
			-- if self.vel == vec2(0,1) then
			-- 	spr(38, screenPos.x, screenPos.y)
			-- elseif self.vel == vec2(0,-1) or self.vel == vec2(0,0) then
			-- 	spr(36, screenPos.x, screenPos.y)
			-- elseif self.vel == vec2(1,0) then
			-- 	spr(37, screenPos.x, screenPos.y)
			-- elseif self.vel == vec2(-1,0) then
			-- 	spr(35, screenPos.x, screenPos.y)
			-- end

			-- if self.vel == vec2(0,1) then
			-- 	spr(38, screenPos.x-4, screenPos.y+5)
			-- elseif self.vel == vec2(0,-1) or self.vel == vec2(0,0) then
			-- 	spr(36, screenPos.x+4, screenPos.y-1)
			-- elseif self.vel == vec2(1,0) then
			-- 	spr(37, screenPos.x+6, screenPos.y)
			-- elseif self.vel == vec2(-1,0) then
			-- 	spr(35, screenPos.x-6, screenPos.y)
			-- end


			spr(self.spriteNumber, screenPos.x, screenPos.y)
			if self.vel == vec2(0,1) then
				spr(38, screenPos.x-4, screenPos.y+5)
			elseif self.vel == vec2(0,-1) or self.vel == vec2(0,0) then
				spr(36, screenPos.x+4, screenPos.y-1)
			elseif self.vel == vec2(1,0) then
				spr(37, screenPos.x+6, screenPos.y)
			elseif self.vel == vec2(-1,0) then
				spr(35, screenPos.x-6, screenPos.y)
			end

		end,
		drawCrossHairs = function(self)
			local crossHairs = getMousePos()
			spr(32, crossHairs.x, crossHairs.y, 2, 2)
		end,
		update = function(self)
			if btn(dirs.left) or btn(dirs.left) then
				self.queuedMove = vec2(-1,0)
			elseif btn(dirs.right) or btn(dirs.right) then
				self.queuedMove = vec2(1,0)
			elseif btn(dirs.up) or btn(dirs.up) then
				self.queuedMove = vec2(0,-1)
			elseif btn(dirs.down) or btn(dirs.down) then
				self.queuedMove = vec2(0,1)
			end
			
			if (self.tilePos:flr() == self.tilePos) then
				if fget(mget(self.tilePos.x, self.tilePos.y), 1) then
					pickUpShell(self.tilePos, self)
					-- TODO sfx
				end
			end

			moveEntity(self)
			self.shootCountdown -= 1
			self:tryShoot()
			
		end,
		tryShoot = tryShoot
	}
end

function pickUpShell(loc, self)
	mset(loc.x, loc.y, 0)
	self.shells += 1
end

function wrapAround(entity) 
	if entity.tilePos.x < -0.5 then
		entity.tilePos.x = 15.5
	elseif entity.tilePos.x > 15.5 then
		entity.tilePos.x = -0.5		
	end
end


function wrapAroundProj(entity) 
	if entity.pos.x < 0 then
		entity.pos.x = 127
	elseif entity.pos.x > 127 then
		entity.pos.x = 0
	end
end




function tryShoot(self)
	-- gs.isGameOver = truef
	if btnp(dirs.x, self.enemyId) then
		if self.shells <= 0 then
			sfx(18)
		end
		if self.shootCountdown <= 0
			and self.shells > 0 
			then

			-- local target = getMousePos()
			local target = self:getCenter() + self.vel
			self.shells -= 1
			-- TODO
			gs.shotsFired += 1
			sfx(20)
			gs.camShakeCount = 3
			for i = 1, 4 do
				local projPos = self:getCenter()
				-- TODO
				local ang = (target - projPos):angle()
				local spread = 0.1
				ang += rnd(spread) - spread/2
				local projVel = vec2fromAngle(ang) * 150
				add(gs.projectiles, makeProjectile(
						projPos,
						projVel,
						self
					))
			end
			self.shootCountdown = self.shootCooldown
		end
	end
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

function makeProjectile(pos, vel, owner)
	return {
		-- These are screen coords, not tile coords
		pos = pos,
		vel = vel,
		owner = owner,
		isDead = false,
		deadCounter = 10,
		update = function(self)
			if self.isDead then
				self.deadCounter -= 1
				return
			end
			self.pos += self.vel * gs.dt
			if not canMoveThere(self.pos/8, vec2(0,0)) then
				self.isDead = true
			end
			wrapAroundProj(self)
			for enemy in all(gs.enemies) do
				if enemy != self.owner then

					if (not enemy.isDead and
						enemy:getCenter():isWithin(self.pos, 5))
						 then
						enemy.health -= self.damage
						-- del(gs.projectiles, self)
						self.isDead = true
						break
						-- TODO maybe blood animation
						-- No break, allow multikill
					end
				end

			end
		end,
		draw = function(self)
			if self.isDead then
				pset(self.pos.x, self.pos.y, 0)
			else
				if gs:isMultiplayer() then
					local col = ({
						[17] = 9,
						[18] = 12,
						[19] = 8,
						[20] = 14
					})[self.owner.spriteNumber]
					pset(self.pos.x, self.pos.y, col)
				else
					pset(self.pos.x, self.pos.y, 10)
				end
			end
		end,
		damage = 100
	}
end

function vec2(x, y)
	local ret = {
		x = x,
		y = y,
		norm = function(self)
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
			return sqrt(dx * dx + dy * dy)
			-- return approx_magnitude(dx, dy)
		end,
		flr = function(self)
			return vec2(flr(self.x), flr(self.y))
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
	return gs.currentAnimation != nil and costatus(gs.currentAnimation) != 'dead'
end

function acceptInput()

end

function resetLevelAfterDeath()
	if gs.player.lives < 0 then
		gs.isGameOver = true

		return
	end
	gs.projectiles = {}
	gs.player.tilePos = vec2(8,8)
	gs.player.shells = 0
	gs.player.spriteNumber = 1
	for enemy in all(gs.enemies) do
		if not enemy.isDead then
			enemy.tilePos = enemy.originalPos
		end
	end
end

function _update()
	-- if btnp(dirs.x) then
	-- 	-- gs.player.isDead = true
	-- 	gs.player.lives -= 1
	-- 				resetLevelAfterDeath()
	-- end
	if gs.isGameOver then
		if gs.endTime == nil then
			gs.endTime = t()
		end
		-- Restart
		if btnp(dirs.x) then
			_init(gs.numPlayers)
		end
		return
	end

	if hasAnimation() then
		local active, exception = coresume(gs.currentAnimation)
		if exception then
			print('',0,0)
			color(7)
			stop(trace(gs.currentAnimation, exception))
		end

		return
	end

	acceptInput()
	if not gs:isMultiplayer() then
		gs.player:update()
	end
	local allEnemiesDead = true
	for enemy in all(gs.enemies) do
		enemy:update()
		if not enemy.isDead and not gs:isMultiplayer() then 
			allEnemiesDead = false
			if enemy.tilePos:isWithin(gs.player.tilePos, 0.5) then
				-- TODO death animation
				-- gs.player.lives -= 1
				gs.currentAnimation = cocreate(function()
					music(-1)
					music(3)
					for i = 1, 30 do
						gs.player.spriteNumber = 56 + i\5
						yield()
					end
					gs.player.lives -= 1
					resetLevelAfterDeath()
				end)
			end
		end
	end
	for projectile in all(gs.projectiles) do
		projectile:update()
		if projectile.isDead and projectile.deadCounter < 0 then
			del(gs.projectiles, projectile)
		end
	end

	if allEnemiesDead and not gs:isMultiplayer() then
		gs.currentAnimation = cocreate(function()
			for i = 1, 10 do 
				-- TODO victory sfx
				yield()
			end
			increaseLevel()
		end)
	end

	if gs:isMultiplayer() then
		checkMultiplayerGameOver()
	end
end

function anyBulletsOnGround()
	for x = 0, 15 do
		for y = 0, 15 do
			if fget(mget(x,y), 1) then
				return true
			end
		end
	end
	return false
end

function checkMultiplayerGameOver()
	if gs.gameOverCountdown != nil then
		gs.gameOverCountdown -= 1
		-- print(gs.gameOverCountdown)
		if gs.gameOverCountdown < 0 then
			gs.isGameOver = true
		end
		return
	end
	for proj in all(gs.projectiles) do
		if not proj.isDead then
			return
		end
	end

	local aliveCount = 0
	local lastAlive = nil
	for enemy in all(gs.enemies) do
		if not enemy.isDead then
			aliveCount += 1
			lastAlive = enemy
		end
	end
	local isGameOver = false
	local gameOverState = nil
	if aliveCount == 1 then
		isGameOver = true
		if lastAlive.enemyId == 0 then
			gameOverState = '\fcplayer 1\f7 wins!'
		elseif lastAlive.enemyId == 1 then
			gameOverState = '\f8player 2\f7 wins!'
		elseif lastAlive.enemyId == 2 then
			gameOverState = '\feplayer 3\f7 wins!'
		elseif lastAlive.enemyId == 3 then
			gameOverState = '\f9player 4\f7 wins!'
		else
			gameOverState = 'error'
		end
	elseif aliveCount == 0 then
		isGameOver = true
		gameOverState = "\f7it's a draw!"
	else
		local nobullets = true
		for enemy in all(gs.enemies) do
			if enemy.shells > 0 then
				nobullets = false
			end
		end
		if nobullets and not anyBulletsOnGround() then
			isGameOver = true
			gameOverState = "\f7stalemate"
		end
	end

	if isGameOver then
		gs.gameOverState = gameOverState
		gs.gameOverCountdown = 20
	end
	-- if isGameOver then
	-- 	gs.currentAnimation = cocreate(function()
	-- 		for i = 1, 20 do
	-- 			yield()
	-- 		end
	-- 		gs.isGameOver = isGameOver
	-- 		gs.gameOverState = gameOverState
	-- 	end)
	-- end
end

function drawGameOverWin()

end

function drawGameOverLose()
	if gs:isMultiplayer() then
		print('\n ' .. gs.gameOverState
			.. '\n\n press ❎ to play again')
	else
		print('\n level: '..gs.level
			.. '\n\n enemies defeated: ' .. gs.enemiesKilled
			.. '\n\n shots fired: ' .. gs.shotsFired
			.. '\n\n\n'
			.. ' press ❎ to play again',
			8,8,7)
	end
end

function _draw()
	cls(0)
	if gs.isGameOver then
		if gs.gameOverState == gameOverWin then
			drawGameOverWin()
		else
			drawGameOverLose()
		end
		return
	end
	camera()
	if gs.camShakeCount > 0 then
		camera(rnd(1)-.5, rnd(1)-.5)
		gs.camShakeCount -= 1
	end
	-- Draw
	map(0,0,0,0,16,16)
	for enemy in all(gs.enemies) do
		enemy:draw()
	end
	for projectile in all(gs.projectiles) do
		projectile:draw()
	end
	if not gs:isMultiplayer() then
		gs.player:draw()
	end

	-- gs.player:drawCrossHairs()

	drawHud()
end


corners2 = {
	vec2(0,-.125),
	vec2(14-.5,-.125),
	vec2(0,15),
	vec2(14,15)
}

function drawHud()
	if gs:isMultiplayer() then
		for ind = 1, #gs.enemies do
			local corner = corners2[ind%4+1] * 8
			local enemy = gs.enemies[ind]
			local col = 7
			if enemy.shells <= 0 then
				col = 8
			end
			spr(40 + ind, corner.x, corner.y)
			local yoff = 0
			if corner.y < 8 then
				yoff = 1
			end
			print('X' .. enemy.shells, corner.x + 8, corner.y+1+yoff, col)
		end
	else
		spr(9, 16, 120)
		local col = 7
		if gs.player.shells <= 0 then
			col = 8
		end
		print('X' .. gs.player.shells, 24,121, col)

		spr(12, 96, 120)
		print('X' .. gs.player.lives, 104, 121, 7)

		print('level ' .. gs.level, 55, 121, 7)
	end
end

#include shim.lua





__gfx__
0000000000aaaa0000a00a0000aaaa0000aaaa000000000000000000000000000c1111c0000000000c1111c0000000000e808200000600000000000001111110
000000000aaaaaa00aa00aa00aaaaaa00aaaaaa0000000000000000000000000c11111c0008e82000c11111ccccccccce8888820000600000000000011111111
00700700aaaaaaaaaaa00aaaaaaaaaaaaaaaaaaa000000000000000000000000111111c0008e82000c11111111111111e8888820000600000000000011111111
00077000000aaaaaaaaaaaaaaaaaa000aaaaaaaa6666dd5000000000000ff000111111c0008e82000c11111111111111e8888820000600000000000011111111
00077000000aaaaaaaaaaaaaaaaaa000aaaaaaaa0000054400000000000ff000111111c0008e82000c111111111111110e888200000600000000000011111111
00700700aaaaaaaaaaaaaaaaaaaaaaaaaaa00aaa000000040000000000000000111111c0008e82000c1111111111111100e82000000650000000000011111111
000000000aaaaaa00aaaaaa00aaaaaa00aa00aa0000000000000000000000000c11111c00097a4000c11111cc111111c000e0000000640000000000011111111
0000000000aaaa0000aaaa0000aaaa0000a00a000000000000000000000000000c1111c00097a4000c1111c00c1111c000000000000044000000000001111110
000000000099990000cccc000088880000eeee000011110000000000000000000c1111c0000000000c1111c00000000000000000000000000c1111c00c1111c0
00000000099999900cccccc0088888800eeeeee0011111100000000000000000c111111c00cccc000c1111c0cccccccccccccc0000cccccc0c11111cc11111c0
0000000097799779c77cc77c87788778e77ee77e177117710000000000000000111111110c1111c00c1111c011111111111111c00c1111110c111111111111c0
0000000097199179c71cc17c87188178e71ee17e177117710000000000000000111111110c1111c00c1111c011111111111111c00c1111110c111111111111c0
0000000099999999cccccccc88888888eeeeeeee111111110000000000000000111111110c1111c00c1111c011111111111111c00c1111110c111111111111c0
0000000099999999cccccccc88888888eeeeeeee117171110000000000000000111111110c1111c00c1111c011111111111111c00c1111110c111111111111c0
0000000099999999cccccccc88888888eeeeeeee111717110000000000000000cccccccc00cccc000c1111c0ccccccccc11111c00c11111c00cccccccccccc00
0000000090999909c0cccc0c80888808e0eeee0e10111101000000000000000000000000000000000c1111c0000000000c1111c00c1111c00000000000000000
000006666600000000000000000000000000600000000000000044000000000000000000000000000000000000000000000000000c1111c00000000000000000
00066006006600000000000000000000000660000000000000054000000000000000000000c6c500008e8200009a940000efe4000c1111c0cccccc0000cccc00
006000060000600000000000000000000006600000000000000d5000000000000000000000c6c500008e8200009a940000efe4000c1111c0111111c00c1111c0
0600000600000600000000006666dd500006600005dd6666000d6000000000000000000000c6c500008e8200009a940000efe4000c1111c0111111c00c1111c0
060000060000060000000000066665440006d0004456666000066000000000000000000000c6c500008e8200009a940000efe4000c1111c0111111c00c1111c0
600000000000006000000000000000040005d0004000000000066000000000000000000000c6c500008e8200009a940000efe4000c1111c0111111c00c1111c0
6000000000000060000000000000000000045000000000000006600000000000000000000097a4000097a40000676d0000676d0000cccc00cccccc000c1111c0
6666600000666660000000000000000000440000000000000006000000000000000000000097a4000097a40000676d0000676d0000000000000000000c1111c0
600000000000006000000000000000000000600000000000000000000000000000aaaa0000a00a00000000000000000000000000000000000000000000000000
60000000000000600000000000000000000060000000000000000000000000000aaaaaa00aa00aa00a0000a00000000000000000000000000000000000cccccc
0600000600000600000000000000000000006000000000000000000000000000aaaaaaaaaaa00aaaaa0000aa000000000000000000000000000000000c111111
0600000600000600000000000000000000006000000000000000000000000000aaaaaaaaaaa00aaaaaa00aaa000000000000000000000000000000000c111111
0060000600006000000000000000000000006000000000000000000000000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa000aa0000000a000000000000c111111
0006600600660000000000000000000000056000000000000000000000000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa00aaaa000000a000000000000c111111
00000666660000000000000000000000000460000000000000000000000000000aaaaaa00aaaaaa00aaaaaa00aaaaaa00aaaaaa0000aaa000000000000cccccc
000000000000000000000000000000000044000000000000000000000000000000aaaa0000aaaa0000aaaa0000aaaa0000aaaa00000aaa000000000000000000
__label__
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc2288ee888822cccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc2288ee888822cccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc2288ee888822cccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc2288ee888822cccccccccc
cccccccc777777cccc7777cccc77cc77cc777777cccc7777cccc777777cccccccccccccc77777777cccccc7777cccc7777cccccccc2288ee888822cccccccccc
cccccccc777777cccc7777cccc77cc77cc777777cccc7777cccc777777cccccccccccccc77777777cccccc7777cccc7777cccccccc2288ee888822cccccccccc
cccccccc775577cc775577cccc77cc77cc775577cc775577cccc775577cccccccccccccc7755775577cc775577cccc775577cccccc2288ee888822cccccccccc
cccccccc775577cc775577cccc77cc77cc775577cc775577cccc775577cccccccccccccc7755775577cc775577cccc775577cccccc2288ee888822cccccccccc
cccccccc77cc77cc77cc77cccc77cc77cc777777cc77cc77cccc77cc55cc7777777777cc77cc77cc77cc77cc77cccc77cc77cccccc2288ee888822cccccccccc
cccccccc77cc77cc77cc77cccc77cc77cc777777cc77cc77cccc77cc55cc7777777777cc77cc77cc77cc77cc77cccc77cc77cccccc2288ee888822cccccccccc
cccccccc777777cc77777777cc557755cc775577cc77777777cc77cccccccccccccccccc77cc77cc77cc77777777cc77cc77cccccc2288ee888822cccccccccc
cccccccc777777cc77777777cc557755cc775577cc77777777cc77cccccccccccccccccc77cc77cc77cc77777777cc77cc77cccccc2288ee888822cccccccccc
cccccccc775555cc77557755cccc77cccc77cc77cc77557755cc77cc77cccccccccccccc77cc77cc77cc77557755cc77cc77cccccc2288ee888822cccccccccc
cccccccc775555cc77557755cccc77cccc77cc77cc77557755cc77cc77cccccccccccccc77cc77cc77cc77557755cc77cc77cccccc2288ee888822cccccccccc
cccccccc77cccccc77cc77cccccc77cccc777777cc77cc77cccc777777cccccccccccccc77cc77cc77cc77cc77cccc77cc77cccccc2288ee888822cccccccccc
cccccccc77cccccc77cc77cccccc77cccc777777cc77cc77cccc777777cccccccccccccc77cc77cc77cc77cc77cccc77cc77cccccc2288ee888822cccccccccc
cccccccc55cccccc55cc55cccccc55cccc555555cc55cc55cccc555555cccccccccccccc55cc55cc55cc55cc55cccc55cc55cccccc99aa77aa9944cccccccccc
cccccccc55cccccc55cc55cccccc55cccc555555cc55cc55cccc555555cccccccccccccc55cc55cc55cc55cc55cccc55cc55cccccc99aa77aa9944cccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc99aa77aa9944cccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc99aa77aa9944cccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc9999aa77aa994444cccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc9999aa77aa994444cccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000cccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000cccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccc0000aaaaaaaaaaaaaaaaaaaaaa0000cccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccc0000aaaaaaaaaaaaaaaaaaaaaa0000cccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccc00000000000000cccccccccc000000aaaaaaaaaaaaaaaa7777777777aaaa00cccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccc00000000000000cccccccccc000000aaaaaaaaaaaaaaaa7777777777aaaa00cccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccc0088888888888800000000cc00aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa777777aa00cccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccc0088888888888800000000cc00aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa777777aa00cccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccc008888888888888888888800aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa00cccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccc008888888888888888888800aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa00cccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccc008800000000000000000000000000000000000000000000000000aaaaaaaaaaaaaaaa00cccccccccccccccccccccccccccccccccccccccccc
cccccccccccccc008800000000000000000000000000000000000000000000000000aaaaaaaaaaaaaaaa00cccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccc00cc00888888888888880000888888888888888888888888888800000000000000000000cccccccccccccccccccccccccccccccccccccccc
cccccccccccccccc00cc00888888888888880000888888888888888888888888888800000000000000000000cccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccc0088888888880000aaaa008888888888888888888888888888888888888888888800cccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccc0088888888880000aaaa008888888888888888888888888888888888888888888800cccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccc0088000000000000aaaaaaaa0000000088888888888888888888888888888888888800cccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccc0088000000000000aaaaaaaa0000000088888888888888888888888888888888888800cccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccc00cccccc0000aaaaaaaaaa9999999900000000000000000000008888888888888800cccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccc00cccccc0000aaaaaaaaaa9999999900000000000000000000008888888888888800cccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccc00aaaaaaaaaaaaaa999900aaaaaaaaaaaaaaaaaaaa0000000000000000cccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccc00aaaaaaaaaaaaaa999900aaaaaaaaaaaaaaaaaaaa0000000000000000cccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccc00aaaaaa777777aaaaaa999900aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa0000cccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccc00aaaaaa777777aaaaaa999900aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa0000cccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccc00aaaaaaaaaa7777aaaaaa9900aaaaaaaaaaaaaaaaaaaaaa0000000000cccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccc00aaaaaaaaaa7777aaaaaa9900aaaaaaaaaaaaaaaaaaaaaa0000000000cccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccc00aaaaaaaaaaaa7777aaaa9900aaaaaaaaaa00000000000000cccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccc00aaaaaaaaaaaa7777aaaa9900aaaaaaaaaa00000000000000cccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccc00aaaaaaaaaaaaaa77aaaa9900aaaaaa000000cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccc00aaaaaaaaaaaaaa77aaaa9900aaaaaa000000cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccc00aaaaaaaaaaaa77aaaa9900aaaaaaaaaa000000cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccc00aaaaaaaaaaaa77aaaa9900aaaaaaaaaa000000cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccc00aaaaaaaaaaaaaaaaaaaa00aaaaaaaa77aaaa000000cccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccc00aaaaaaaaaaaaaaaaaaaa00aaaaaaaa77aaaa000000cccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccc00aaaaaaaaaaaaaaaa990099aaaaaaaa777777aaaa000000cccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccc00aaaaaaaaaaaaaaaa990099aaaaaaaa777777aaaa000000cccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccc00aaaaaaaaaaaaaaaa000099aaaaaaaaaaaa7777aaaaaa000000cccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccc00aaaaaaaaaaaaaaaa000099aaaaaaaaaaaa7777aaaaaa000000cccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccc00aaaaaaaaaa990099999999aaaaaaaaaaaaaaaaaaaaaaaa0000cccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccc00aaaaaaaaaa990099999999aaaaaaaaaaaaaaaaaaaaaaaa0000cccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccc00aaaaaaaaaaaa990099999999999999aaaaaaaaaaaaaaaaaa009900cccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccc00aaaaaaaaaaaa990099999999999999aaaaaaaaaaaaaaaaaa009900cccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccc00aaaaaa00aaaa99000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccc00aaaaaa00aaaa99000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccc00aa77aaaa000000005555555555555555555555555555555555666666666666666666666666555555666666555555555500
cccccccccccccccccccccccccccc00aa77aaaa000000005555555555555555555555555555555555666666666666666666666666555555666666555555555500
cccccccccccccccccccccccccccc00aa77aaaaaaaaaa000000005555666666665555000000000000000000000000555555555555555555555555555555555500
cccccccccccccccccccccccccccc00aa77aaaaaaaaaa000000005555666666665555000000000000000000000000555555555555555555555555555555555500
cccccccccccccccccccccccccccc00aa7777aaaaaaaaaaaaaaaa000055555555555500aa00aa0000009999444444005555555555000000000000000000000000
cccccccccccccccccccccccccccc00aa7777aaaaaaaaaaaaaaaa000055555555555500aa00aa0000009999444444005555555555000000000000000000000000
cccccccccccccccccccccccccccc00aaaa77aaaaaaaaaaaaaaaaaaaa00000055555500aa00aa00aa00444444444400555555555500cccccccccccccccccccccc
cccccccccccccccccccccccccccc00aaaa77aaaaaaaaaaaaaaaaaaaa00000055555500aa00aa00aa00444444444400555555555500cccccccccccccccccccccc
cccccccccccccccccccccccccc000000aaaaaaaaaaaaaaaa00aa00aaaaaa0000550000aa00aa00aa004444444444000000000000cccccccccccccccccccccccc
cccccccccccccccccccccccccc000000aaaaaaaaaaaaaaaa00aa00aaaaaa0000550000aa00aa00aa004444444444000000000000cccccccccccccccccccccccc
cccccccccccccccccccccc000044440099999999aa00aa00aa00aa00aa0055555500aaaa00aa00aa000000000000cccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccc000044440099999999aa00aa00aa00aa00aa0055555500aaaa00aa00aa000000000000cccccccccccccccccccccccccccccccccccc
cccccccccccccc000000009999444400000000000000aa00aa00aa00aa0000000000aaaaaa00aa0000999900cccccccccccccccccccccccccccccccccccccccc
cccccccccccccc000000009999444400000000000000aa00aa00aa00aa0000000000aaaaaa00aa0000999900cccccccccccccccccccccccccccccccccccccccc
cccccc000000004499999999444400665555550000000000aa00aa000000cccccc0000aaaaaa000099999900cccccccccccccccccccccccccccccccccccccccc
cccccc000000004499999999444400665555550000000000aa00aa000000cccccc0000aaaaaa000099999900cccccccccccccccccccccccccccccccccccccccc
cccc004499994444444444444400440055550000cccccc000000aa00cccccccccccccc000000999999aa00cccccccccccccccccccccccccccccccccccccccccc
cccc004499994444444444444400440055550000cccccc000000aa00cccccccccccccc000000999999aa00cccccccccccccccccccccccccccccccccccccccccc
cc0044444444444444444444444444005500cccccccccccccc000000cccccccccccccccccccc0000aa00cccccccccccccccccccccccccccccccccccccccccccc
cc0044444444444444444444444444005500cccccccccccccc000000cccccccccccccccccccc0000aa00cccccccccccccccccccccccccccccccccccccccccccc
cccc00444444444444444444444400555500cccccccccccccccccc0000000000000000000000cccc00cccccccccccccccccccccccccccccccccccccccccccccc
cccc00444444444444444444444400555500cccccccccccccccccc0000000000000000000000cccc00cccccccccccccccccccccccccccccccccccccccccccccc
cccc004444444444444444444400cc0000cccccccccccccccc0000666666666666666666555500cccccccccccccccccccccccccccccccccccccccccccccccccc
cccc004444444444444444444400cc0000cccccccccccccccc0000666666666666666666555500cccccccccccccccccccccccccccccccccccccccccccccccccc
cccc0044444444444444440000cccccccccccccccccccccc00666677776677666666666666665500cccccccccccccccccccccccccccccccccccccccccccccccc
cccc0044444444444444440000cccccccccccccccccccccc00666677776677666666666666665500cccccccccccccccccccccccccccccccccccccccccccccccc
cccc004444444444222200cccccccccccccccccccccccc006666666666666666666666666666665500cccccccccccccccccccccccccccccccccccccccccccccc
cccc004444444444222200cccccccccccccccccccccccc006666666666666666666666666666665500cccccccccccccccccccccccccccccccccccccccccccccc
cc004444222244000000cccccccccccccccccccccccc0066555566556666555555666655555566665500cccccccccccccccccccccccccccccccccccccccccccc
cc004444222244000000cccccccccccccccccccccccc0066555566556666555555666655555566665500cccccccccccccccccccccccccccccccccccccccccccc
cc00222200000000cccccccccccccccccccccccccccc0066556655665566556655666655666666665500cccccccccccccccccccccccccccccccccccccccccccc
cc00222200000000cccccccccccccccccccccccccccc0066556655665566556655666655666666665500cccccccccccccccccccccccccccccccccccccccccccc
cccc0000cccccccccccccccccccccccccccccccccc00666655665566556655556666666655666666665500cccccccccccccccccccccccccccccccccccccccccc
cccc0000cccccccccccccccccccccccccccccccccc00666655665566556655556666666655666666665500cccccccccccccccccccccccccccccccccccccccccc
ddcccccccccccccccccccccccccccccccccccccccc00666655666666556655665566666666556666665500555555555555cccccccccccccccccccccccccccccc
ddcccccccccccccccccccccccccccccccccccccccc00666655666666556655665566666666556666665500555555555555cccccccccccccccccccccccccccccc
555555cccccccccccccccc55555555555555cccccc0066665566666655665566665566555566665566550033223333bb3355cccccccccccccc55555555555555
555555cccccccccccccccc55555555555555cccccc0066665566666655665566665566555566665566550033223333bb3355cccccccccccccc55555555555555
3333335555cccccc55555533bb33bb33335555550066666666666666666666666666666666666666666655003333bb33333355cccccccc55553333bb33333333
3333335555cccccc55555533bb33bb33335555550066666666666666666666666666666666666666666655003333bb33333355cccccccc55553333bb33333333
2233bb3355cc555533333333333333332233333300667766666666665555555555556666666666666666550033333322333355cccc5555333333333333bb3322
2233bb3355cc555533333333333333332233333300667766666666665555555555556666666666666666550033333322333355cccc5555333333333333bb3322
3333333333553333bbbb333322333333333333330066776666666666556666666666556666666666666655003333333333bb3355553333bb3333223333333333
3333333333553333bbbb333322333333333333330066776666666666556666666666556666666666666655003333333333bb3355553333bb3333223333333333
bb33223333333333333333333333223333bb3333006666666666665566666666665566666666666666665500332233bb333333333333bb33bb33333322333333
bb33223333333333333333333333223333bb3333006666666666665566666666665566666666666666665500332233bb333333333333bb33bb33333322333333
33333333333333333333333333333333333333220066776666666655666666665566666666666666666655003333333333332233333333333333333333333333
33333333333333333333333333333333333333220066776666666655666666665566666666666666666655003333333333332233333333333333333333333333
55555555555555555555555555555555555555550066666666666655666666666655666666666666666655005555555555555555555555555555555555555555
55555555555555555555555555555555555555550066666666666655666666666655666666666666666655005555555555555555555555555555555555555555
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb006666666666666655666666666655666666666666665500bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb006666666666666655666666666655666666666666665500bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb006666666666666666555555555566666666666666665500bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb006666666666666666555555555566666666666666665500bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb

__gff__
0000000000000002010001010000000100000000000000000101010101010101000000000000000000000000000101010000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1d1b1b1b1b1b1b0b1b1b1b1b1b1b1b1c0d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a0707070707071a070707070707071a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a0719073f2e072d073f2e073f2e071a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a07070707070707070707070707071a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a071d1b1b2e072f073f1b1b2e073f0800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a071a070707072d070707070707071a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2d072d073f2e07073f1b1b1b1b2e072d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0707070707072f07070707070707070700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f0707072f072d070719072f0707072f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a073f1b1f0707072f07070a1b2e071a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a07070707072f071a071d1f0707071a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a073f1b1b1b1f072d072d070719071a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a07070707070707070707070707071a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a073f2e073f2e072f073f2e0719071a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a070707070707071a0707070707071a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1e1b1b1b1b1b1b1b181b1b1b1b1b1b1f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
01082000185501855524550245551f5501f5551c5501c555245551f55500000000001c5550000000000000001955019555255502555520550205551d5501d555255552055500000000001d555000000000000000
0104200018550185501855018555245502455024550245551f5501f5501f5501f5551c5501c5501c5501c55524550245551f5501f555000000000000000000001c5501c555000000000000000000000000000000
010420001b5501b5551c5501c5551d5501d55500000000001d5501d5551e5501e5551f5501f55500000000001f5501f5552055020555215502155500000000002455024555000000000000000000000000000000
010820000c5550055518555000000000000000065550755510555005550055500000000000000007550075550d555015551955500000000000000007555085551155501555015550000000000000000855008555
01082000015550c555000000000010550105501055501555000000000000000000000c5500c5500c5500c555025550d555000000000011550115501155502555000000000000000000000d5500d5500d5500d555
01042000000000000008550085550000000000000000000000000000000a5500a5550000000000000000000000000000000c5500c555000000000000000000000c5500c5500c5500c5500c5500c5500c5500c555
010420000c5500c555005500055518550185550000000000000000000000000000000655006555075500755510550105550055000555005500055500000000000000000000000000000007550075500755007555
0104200008555075500755507555075500755007550075550a555095500955509555095500955009550095550c5550b5500b5550b5550b5500b5500b5500b5500b5500b5500b5500b55500550005500055000555
010420000155001555000000c5500c55500000000000000000000000000000010550105501055010550105501055010550105550155001555000000000000000000000000000000000000000000000000000c550
010420000c5500c5500c5500c5500c5500c5500c5500c5500c5500c55500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01032000325653156532565315653056531565305652f565305652f5652e5652f5652e5652d5652c5652d5652c5652b5652c5652b5652a5652b5652a565295652a56529565285652756528565275652656527565
01032000265652556526565255652456525565245652356522565235652256521565225652156520565215651c5651f5652356526565000001c5651f565235652656026565000000000000000000000000000000
010820000516005150051500515005150051500c1600c150000000000000000000000f1600f1500f1500f15000000000000000000000000000000000000000000000000000000000000000000000000000000000
010820000816008150081500815008150081500d1600d150000000000000000000001116011150111501115000000000000000000000000000000000000000000000000000000000000000000000000000000000
010820000516005150051500515005150051500c1600c150000000000000000000000e1600e1500e1500e150000000000000000000000c1600c1500c1500c1500000000000000000000005160051500515005150
010820000516005150051500515005150051500c1600c150000000000000000000000e1600e1500e1500e15000000000000c1600c1500c1500c1500c1500c1500516005150051500515005150051500515005150
010820000e5300e535125301253515530155351a5301a535005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
0108200009530095350e535125301253509530095350e535005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
00010000186502163002630056403e6400c6401b6400c600346002060017600000000000000000016000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000396400b65039650316400b64035640356200965039630366400a6403763037630256501e6501965016650006000060000600006000060000600006000060000600006000060000600006000060000600
000100003c6503965035650326502f6502b650296502665027650296502e65034650276501f650126500e65000600006000060000600006000060000600006000060000600006000060000600006000060000600
010400002c5652b5652c5652b5652a5652b5652a56529565000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300001c5651f5652356526565000001c5651f56523565265602656500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 00030440
00 01060840
04 02050709
00 0a404040
04 0b404040
01 0c404040
00 0d404040
00 0e404040
02 0f404040
04 10114040

__meta:cart_info_start__
cart_type: game
# Embed: 750 x 680
game_name: Paybac-Man
# Leave blank to use game-name
game_slug: 
jam_info:
  - jam_name: TriJam
    jam_number: 190
    jam_url: null
    jam_theme: 'Surrounded by enemies'
  - jam_name: MiniJam
    jam_number: 117
    jam_url: 'https://itch.io/jam/mini-jam-117-ghosts'
    jam_theme: 'Ghosts'
    minijam_limitation: 'Shotgun as a mechanic'
tagline: Live for nothing, or die for something
time_left: '0:0:0'
develop_time: 3h
description: |
  You are surrounded by enemies on all sides.
  Collect ammo and use your shotgun to defeat the ghosts.
  Defeat all the ghosts to move to the next level.

  Supports 2 player competitive
controls:
  - inputs: [ARROW_KEYS]
    desc: Move
  - inputs: [X]
    desc: Shoot
  - inputs: [P]
    desc: Pause menu. Allows selecting 2 player mode
  - inputs: [ESDF]
    desc: Move (player 2)
  - inputs: [A]
    desc: Shoot (player 2)
hints: |
  * Pay attention to how much ammo you have
  * Collect ammo around the map
acknowledgements: |
  * Based on [Pac-Man](https://en.wikipedia.org/wiki/Pac-Man)
  * Music from [GPI](https://www.lexaloffle.com/bbs/?uid=58188)'s [Pic-Man](https://www.lexaloffle.com/bbs/?tid=44840). Licensed under [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/)

to_do: []
version: 0.2.0
img_alt: Pac-Man with a shotgun and a Rambo headband at the grave of Mrs. Pac-Man
about_extra: ''
number_players: [1,2]
__meta:cart_info_end__


