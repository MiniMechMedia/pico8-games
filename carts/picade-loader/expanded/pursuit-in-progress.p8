pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
--pursuit in progress            v0.2.0
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

-- TODO add this to template
dirs2 = {
	left = 0,
	up = 1,
	right = 2,
	down = 3
}

dirs2iterable = {
	dirs2.left,
	dirs2.right,
	dirs2.up,
	dirs2.down
}

function dirToDir2(dir)
	if dir == dirs.left then
		return dirs2.left
	elseif dir == dirs.right then
		return dirs2.right
	elseif dir == dirs.up then
		return dirs2.up
	elseif dir == dirs.down then
		return dirs2.down
	else
		assert(false)
	end
end

gameOverWin = 'win'
gameOverLose = 'lose'

gameOverStates = {
	pending = nil,
	perpCaptured = 'perpCaptured',
	copCrashed = 'copCrashed',
	perpCrashed = 'perpCrashed',
	perpEscaped = 'perpEscaped'
}

function _init(isTwoPlayer)
	menuitem(1, '1 player', function()
		_init(false)
	end)
	menuitem(2, '2 player', function()
		_init(true)
	end)
	music(49, 2500)
	gs = {
		isTwoPlayer = isTwoPlayer,
		getElapsedTime = function(self)
			return t() - self.startTime
		end,
		isGameOver = false,
		gameOverState = nil,
		dt = 1/30.0,
		startTime = t(),
		endTime = nil,
		currentAnimation = nil,
		player = makeCar(vec2(51*8, 22*8 + 60), dirs2.up),
		opponent = makeCar(vec2(51*8 - 2, 22*8 - 20 + 30), dirs2.up)
	}
end

function makeCar(pos, facing)
	return {
		pos = pos,
		facing = facing,
		getMapCell = function(self)
			local cell = self.pos / (4 * 8)
			return vec2(flr(cell.x), flr(cell.y))
		end,
		getNativeMapCell = function(self)
			local nativeCell = self.pos / 8
			return vec2(flr(nativeCell.x), flr(nativeCell.y))
		end,
		getMapSprite = function(self)
			local cellVec = self:getNativeMapCell()
			-- return cellVec.y
			return mget(cellVec.x, cellVec.y)
		end,
		isInNewCell = false
	}
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

function vecFromDir2(dir2)
	if dir2 == dirs2.left then
		return vec2(-1, 0)
	elseif dir2 == dirs2.right then
		return vec2(1, 0)
	elseif dir2 == dirs2.up then
		return vec2(0, -1)
	elseif dir2 == dirs2.down then
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
	return gs.currentAnimation != nil and costatus(gs.currentAnimation) != 'dead'
end

function acceptInput(car, playerNumber)
	local newDir2 = nil
	if btnp(dirs.up, playerNumber) then
		newDir2 = dirs2.up
	elseif btnp(dirs.down, playerNumber) then
		newDir2 = dirs2.down
	elseif btnp(dirs.left, playerNumber) then 
		newDir2 = dirs2.left
	elseif btnp(dirs.right, playerNumber) then
		newDir2 = dirs2.right
	end
	-- TODO also check if in intersection
	-- TODO also check if there's a building in front of you??
	if newDir2 != nil and
			vecFromDir2(newDir2) != -1 * vecFromDir2(car.facing)
		then
			car.facing = newDir2
		end
end

function updateCarPositions()
	local speed = 46.3 * 1.9



	-- local opponentInitCell = gs.opponent.pos / (4 * 8)
	-- opponentInitCell = vec2()
	local opponentInitCell = gs.opponent:getMapCell()
	gs.opponent.pos += vecFromDir2(gs.opponent.facing) * speed * gs.dt
	local opponentCurrentCell = gs.opponent:getMapCell()
	if opponentInitCell != opponentCurrentCell then
		gs.opponent.isInNewCell = true
	end

	-- DEBUG
	local speedBonus = gs:getElapsedTime() / 5
	speedBonus = min(speedBonus, 10)
	speed += speedBonus
	gs.player.pos += vecFromDir2(gs.player.facing) * speed * gs.dt

end

function checkGotThePerp()
	local dist = gs.player.pos:squareDist(gs.opponent.pos)
	return dist < 8--20
end

function checkLostThePerp()
	local dist = gs.player.pos:squareDist(gs.opponent.pos)
	return dist > 100
end

function _update()
	if gs.isGameOver then
		if gs.endTime == nil then
			gs.endTime = t()
		end
		-- Restart
		if btnp(dirs.x) then
			_init(gs.isTwoPlayer)
		end
		return
	end

	if hasAnimation() then
		local active, exception = coresume(gs.currentAnimation)
		if exception then
			stop(trace(gs.currentAnimation, exception))
		end

		return
	end

	updateCarPositions()

	checkEndGame()

	acceptInput(gs.player, 0)
	if gs.isTwoPlayer then
		acceptInput(gs.opponent, 1)
	end

	updateOpponentDirection()

end

function checkEndGame(car)
	if fget(gs.player:getMapSprite(), 3) then
		gs.isGameOver = true
		-- TODO animate crashing
		gs.gameOverState = gameOverStates.copCrashed
		sfx(6)
		music(-1)
	elseif fget(gs.opponent:getMapSprite(), 3) then
		gs.isGameOver = true
		gs.gameOverState = gameOverStates.perpCrashed
		sfx(6)
		music(-1)
	elseif checkLostThePerp() then 
		gs.isGameOver = true
		-- TODO animate something else
		gs.gameOverState = gameOverStates.perpEscaped
		music(-1)
		sfx(3)
	elseif checkGotThePerp() then
		gs.isGameOver = true
		gs.gameOverState = gameOverStates.perpCaptured
		music(0, 4000)
	end
end

-- function mymget(pos)
-- 	local cells = pos / 8
-- 	return mget(cells.x, cells.y)
-- end

function opponentIsInInnerCell()
	local cellVec = gs.opponent.pos / 8
	local modX = flr(cellVec.x) % 4
	local modY = flr(cellVec.y) % 4

	return (modX == 1 or modX == 2) and
			(modY == 1 or modY == 2)
end

function updateOpponentDirection()
	if gs.isTwoPlayer then
		return
	end

	if not gs.opponent.isInNewCell then
		return
	end
	if not opponentIsInInnerCell() then
		return
	end

	-- print('\n\n', gs.player.pos.x, gs.player.pos.y, 7)
	local cellVec = gs.opponent.pos / 8
	local opponentTile = mget(cellVec.x, cellVec.y)
	-- If we are not on an intersection, then can't change
	if not fget(opponentTile, 1) then
		return
	end

	local options = {}
	for dir2 in all(dirs2iterable) do
		-- assert(false)
		-- If they are opposing then skip, because opponent can't make a U-turn
		if vecFromDir2(dir2) != -1 * vecFromDir2(gs.opponent.facing) then
			local otherCellVec = cellVec + 4 * vecFromDir2(dir2)
			local otherTile = mget(otherCellVec.x, otherCellVec.y)
			-- Make sure we aren't driving into a building
			if not fget(otherTile, 3) then
				add(options, dir2)
			end
		end
	end

	-- print(#options, 7)
	local newDir = rnd(options)
	if newDir != nil then
		gs.opponent.facing = newDir
	end
	gs.opponent.isInNewCell = false
end

function drawGameOver()
	camera()
	if gs.isTwoPlayer then
		if gs.gameOverState == gameOverStates.perpCaptured then
			print('\n perp was captured!')
			print('\n cop wins!')
			-- print('')
			-- if gs.endTime != nil then
			-- 	local diff = gs.endTime - gs.startTime
			-- 	print(' time to capture: ' .. diff .. ' sec')
			-- end
			-- print('')
			print('')
			print(' press ❎ to play again')
		elseif gs.gameOverState == gameOverStates.copCrashed then
			print('\n cop crashed!')
			print('\n perp wins!')
			print('')
			print(' press ❎ to play again')
		elseif gs.gameOverState == gameOverStates.perpCrashed then
			print('\n perp crashed!')
			print('\n cop wins!')
			print('')
			print(' press ❎ to play again')
		elseif gs.gameOverState == gameOverStates.perpEscaped then
			print('\n perp escaped!')
			print('\n perp wins!')
			print('')
			print(' press ❎ to play again')
		end
	else
		if gs.gameOverState == gameOverStates.perpCaptured then
			print('\n you captured the perp!')
			print('')
			if gs.endTime != nil then
				local diff = gs.endTime - gs.startTime
				print(' time to capture: ' .. diff .. ' sec')
			end
			print('')
			print('')
			print(' press ❎ to play again')
		elseif gs.gameOverState == gameOverStates.copCrashed then
			print('\n you crashed!')
			print('')
			print(' press ❎ to try again')

		elseif gs.gameOverState == gameOverStates.perpEscaped then
			print('\n you lost the perp!')
			print('')
			print(' press ❎ to try again')
		end
	end
end

-- function drawGameOverWin()
-- 	camera()
-- 	print('\n you captured the perp!')
-- 	print('')
-- 	if gs.endTime != nil then
-- 		local diff = gs.endTime - gs.startTime
-- 		print(' time to capture: ' .. diff .. ' sec')
-- 	end
-- 	print('')
-- 	print('')
-- 	print(' press ❎ to play again')
-- end

-- function drawGameOverLose()
-- 	camera()
-- 	if gs.lostThePerp then
-- 		print('\n you lost the perp!')
-- 		print('')
-- 		print(' press ❎ to try again')
-- 	else
-- 		print('\n you crashed!')
-- 		print('')
-- 		print(' press ❎ to try again')
-- 	end
-- end

function drawPlayer()
	local spriteNumber = 1 + 2 * gs.player.facing
	local pos = gs.player.pos
	drawCar(spriteNumber, pos)

	-- print(gs.player:getMapSprite(), pos.x, pos.y)
end

function drawCar(spriteNumber, pos)
	pos = pos - vec2(8, 8)
	palt(0, false)
	palt(14, true)
	spr(spriteNumber, pos.x, pos.y, 2, 2)
	palt()
end

function drawOpponent()
	local spriteNumber = 33 + 2 * gs.opponent.facing
	local pos = gs.opponent.pos
	drawCar(spriteNumber, pos)
end

function drawMap()
	map(0, 0, 0, 0, 256, 256)
end
-- prevCamPos = nil
camHistory = {}
function _draw()
	cls(5)
	if gs.isGameOver then
		drawGameOver()
		-- if gs.gameOverState == gameOverWin then
		-- 	drawGameOverWin()
		-- else
		-- 	drawGameOverLose()
		-- end
		return
	end

	local beta = 0.2
	local hist = 1
	local proj = 0
	local effOppPos = gs.opponent.pos + proj*vecFromDir2(gs.opponent.facing)
	local camPos = (gs.player.pos*beta + effOppPos*(1-beta))

	add(camHistory, camPos)
	if #camHistory > hist then
		deli(camHistory, 1)
	end

	local avCamPos = vec2(0,0)
	for pos in all(camHistory) do
		avCamPos += pos
	end
	avCamPos /= #camHistory
	-- camPos = gs.opponent.pos
	-- local camPos = effOppPos

	-- if prevCamPos == nil then
	-- 	prevCamPos = camPos
	-- end

	-- local alpha = 0.1
	-- camPos = (camPos * alpha + prevCamPos * (1-alpha))
	camPos = avCamPos
	if not gs.isTwoPlayer then
		camPos = gs.player.pos
	end
	camera(camPos.x - 64, camPos.y - 64)
	prevCamPos = camPos

	-- camera(gs.player.pos.x - 64, gs.player.pos.y - 64)
	drawMap()

	drawPlayer()
	drawOpponent()

end

#include shim.lua


-- Here
old_draw = _draw
old_init = _init

ssmemloc = 0x0000
original_saved_ss = 0x8000
picade_saved_ss = 0x8000 + 8192

function init_spritesheet()
	-- -- reload()
	-- -- TODO pass args
	-- if old_init then
	-- 	old_init()
	-- 	return
	-- end
	local fullss = 'bbbbbb00010bbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbb101010101bbbbbb0aaaaaafaffffffffffffff9999999999494444442222222e2eededdddddddcdccccccccc1c1c1c11111111110bbbbbbbbbbbbbbbbbbbbbb00001010101bbbbb0aaaaaaafaffffffffffffff9f99999999494444442222222e2eeddddddddddcdccccccc1c1c1c111111111110bbbbbbbbbbbbbbbbbbbbb0010101111111bbbb0aaaaaaaafafaffffffffffff9f999999994944442422222e2eededdddddddcdccccccc1c1c111111111111110bbbbbbbbbbbbbbbbbbbb000010101011101bbb0aaaaaaaaafafaffffffff66666f9666669946664422266666ed6666666dd666666666cc1c1111111111111110bbbbbbbbbbbbbbbbbbbb000101011116111bbb0aaaaaaaaaafafaffffff6777776f677769667776642267776ee67777776c677777776c1111111111111111100bbbbbbbbbbbbbbbbbbb0000010101167d110bb0aaaaaaaaaaafafafafff677777766777667777777626677776e6777777766777777761c111111111111111010bbbbbbbbbbbbbbbbbbb000010101111d1111bb0aaaaaaaaaaaaaafafaff677777776777667777777666777776e677777777677777776c1111111111111010100bbbbbbbbbbbbbbbbbbb00000101010111010bb0aaaaaaaaaaaaaaafafaf677767776777677776777766777777667777777767776666611111111111110101000bbbbbbbbbbbbbbbbbbb00000010111111111bbb05a5aaaaaaaaaaaafafa67776677677767776666666677677766777667776777777761111111111110101000bbbbbbbbbbbbbbbbbbbb00000101010101010bbb0a5a5a5aaaaaaaaaafaf67777777677767777677776777677766777767776777666661111111110101000000bbbbbbbbbbbbbbbbbbbbb000001010101010bbbb0555a5a5aaaaaaaaaafa67777776677766777777776777767776777777776777777761111111101010000000bbbbbbbbbbbbbbbbbbbbb000000001010101bbbb0555555a5a5aaaaaaaaf67777766677766777777767777767776777777766777777761111101010100000000bbbbbbbbbbbbbbbbbbbbbb0000001010101bbbbb0555555555a5a5aaaaaa6777666f6777696777776677777667767777776c6777777761111010101000000000bbbbbbbbbbbbbbbbbbbbbbb00000000000bbbbbb05555555555a5a5aaaaa66666fff666669966666266666666666666666cc6666666661010101010000000000bbbbbbbbbbbbbbbbbbbbbbbb000000001bbbbbbb05555555555555a5a5aaaaaafafaffff9999494444222e2eeddddddcdccccc1c111110101010000000000000bbbbbbbbbbbbbbbbbbbbbbbbb0000000bbbbbbbb055555555555555a5a5aaaaaafaffff9f9999444422222eededdddcdccccc111111101010100000000000000bbbbbbbbbbbbbbbbbbbbbbb0005d667000bbbbbb055555555555555555a5aaaaaafaffff9999494444222eeeeddddddccccc1111111010100000000000000000bbbbbbbbbbbbbbbbbbbbbb00005d6670101bbbbb0555555555555555555aaaaaaaafaff9f9999444422222eeddddddccccccc111110101000000000000000000bbbbbbbbbbbbbbbbbbbbb000015d66710100bbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbb0000105d667110101bbbbbb05555555555555555aaaaaaaffffff999944442222eeeedddddcccccc1111111000000000000000000bbbbbbbbbbbbbbbbbbbbbbb00000105d51101000bbbbbb0555555557777777777777777777777777777777777777777777777777777777777777777000000000bbbbbbbbbbbbbbbbbbbbbbb00001011111110101bbbbbb0555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7000000000bbbbbbbbbbbbbbbbbbbbbbbb000010101010100bbbbbbb0555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7000000000bbbbbbbbbbbbbbbbbbbbbbbbb0010101010101bbbbbbbb0555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7000000000bbbbbbbbbbbbbbbbbbbbbbbbbb00000010000bbbbbbbbb0555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbb0101010bbbbbbbbbbb0555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000bbbbbbbbbbbbb0555555557bbbbbbbbbbbbbbbbbbbb44444bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7000000000bbbbbb00010bbbbbbbbbbbbbbbb10101101bbbbbbbbbbb0555555557bbbbbbbbbbbbbbbbbb44aaaaafbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7000000000bbbb101010101bbbbbbbbbbbbb0000100101bbbbbbbbbb0555555557bbbbbbbbbbbbbbbbb449aaaaaaf4bbbbbbbb44444bbbbbbbbbbbbbbbbbbbbb7000000000bbb00001010101bbbbbbbbbbb001010111111bbbbbbbbb0555555557bbbbbbbbbbbbbbbb449aaaaaaaaf5bbbbb44aaaaafbbbbbbbbbbbbbbbbbbbb7000000000bb0010101111111bbbbbbbbb00001010011101bbbbbbbb0555555557bbbbbbbbbbbbbbb444aaaaaaaaaafbbbb4a9aaaaaaf4bbbbbbbbbbbbbbbbbb7000000000b000010101011101bbbbbbbb00010101116111bbbbbbbb0555555557bbbbbbbbbbbbbbb444aaaaaaaaaafbbb4a9aaaaaaaaf5bbbbbbbbbbbbbbbbb7000000000b000101011116111bbbbbbb000001010167d110bbbbbbbb055555557bbbbbbbbbbbbbbb4449aaaaaaafafbb444aaaaaaaaaafbbbbbbbbbbbbbbbbb700000000b0000010101167d110bbbbbb0000010100111010bbbbbbbb055555557bbbbbbbbbbbbbbbb4449aaaaffaafbb444aaaaaaaaaafbbbbbbbbbbbbbbbbb700000000b000010101111d1111bbbbbb0000001011111111bbbbbbbb055555557bbbbbbbbbbbbbbbb49999aaaaaaa5bb4449aaaaaaafafbbbbbbbbbbbbbbbbb700000000b00000101010111010bbbbbb0000010100101010bbbbbbbb055555557bbbbbbbbbbbbbbbbb49aaaaaaa45bbbb4449aaaaffaa5bbbbbbbbbbbbbbbbb700000000b00000010111111111bbbbbbb00000101101010bbbbbbbbb055555557bbbbbbbbbbbbbbbbbb44aaaaa45bbbbbb4499aaaaa4bbbbbbbbbbbbbbbbbbb700000000b00000101010101010bbbbbbb00000000010101bbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbb4444bbbbbbbbbbb4444444bbbbbbbbbbbbbbbbbbbb700000000bb000001010101010bbbbbbbbb000000110101bbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bb000000001010101bbbbbbbbbb0000000000bbbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bbb0000001010101bbbbbbbbbbbb00000001bbbbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bbbb000000000007bbbbbbbbbbbbbb0000bbbbbbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bbbbb00000000167000bbbbbbbbbbb5d67bbbbbbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bbbbbbb000005d6670000bbbbbbbbb5d67bbbbbbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bbbbbbbbb0005d66710101bbbbbbb05d6700bbbbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbb24eeee5bbbbbbbbb555d551bbbbbbbbbbbbbbbbbbbb700000000bbbbbbbb000015dd5010100bbbb0005d667000bbbbbbbbbb055555557bbbbbbbbbbbbbbbbbb4eeeeeeedbbbbbbb53cccccd5bbbbbbbbbbbbbbbbbbb700000000bbbbbbb00001015d11110101bb00005dd670101bbbbbbbbb055555557bbbbbbbbbbbbbbbbb4eeeeeeeeedbbbbb5dcccccccd5bbbbbbbbbbbbbbbbbb700000000bbbbbbb00000101111101000b000015dd6710100bbbbbbbb055555557bbbbbbbbbbbbbbbb24eeeeeeeeefdbbb5dcccccccccdbbbbbbbbbbbbbbbbbb700000000bbbbbbb0000101111111010100001015d51110101bbbbbbb055555557bbbbbbbbbbbbbbbb44eeeeeeeeef6bb151cccccccccc5bbbbbbbbbbbbbbbbb700000000bbbbbbbb000010101010100b00000101111101000bbbbbbb055555557bbbbbbbbbbbbbbbb444eeeeeeefefbb1d11cccccccccc5bbbbbbbbbbbbbbbb700000000bbbbbbbbb0010101010101bb00001011111110101bbbbbbb055555557bbbbbbbbbbbbbbbb4444eeeee7feebb51d1dccccccccc5bbbbbbbbbbbbbbbb700000000bbbbbbbbbb00000010000bbbb000010101010100bbbbbbbb055555557bbbbbbbbbbbbbbbb24e44eeefeeedbbd1ddd3cccccccc5bbbbbbbbbbbbbbbb700000000bbbbbbbbbbbb0101010bbbbbbb0010101010101bbbbbbbbb055555557bbbbbbbbbbbbbbbbb44eeeeeeee4bbbf5ddccccccc665bbbbbbbbbbbbbbbbb700000000bbbbbbbbbbbbbbbbbbbbbbbbbbb00000010000bbbbbbbbbb055555557bbbbbbbbbbbbbbbbbb24eeeeee4bbbbbd15dccccc67dbbbbbbbbbbbbbbbbbb700000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbb0101010bbbbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbb2244442bbbbbbbb55dcccccdbbbbbbbbbbbbbbbbbbb700000000bbbbbbbbbbbbb00010bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbdddddddbbbbbbbbbbbbbbbbbbbb700000000bbbbbbbbbbb101010101bbbbbbbbbbbbbbbbbbbbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bbbbbbbbbb00001010101bbbbbbbbbbbbbbbbbbbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bbbbbbbbb0010101111111bbbbbbbb000010bbbbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bbbbbbbb000010101011101bbbbb1010110101bbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bbbbbbbb000101011116111bbbb000010010101bbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bbbbbbb0000010101167d110bb00101011111111bbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bbbbbbb000010101111d1111b0000101001011101bbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bbbbbbb00000101010111010b0001010111116111bbbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbbbbbb0000001011111111100000101001167d110bbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbbbbbb000001010101010100000101011111d1111bbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbbbbbbb000001010101010b000001010010111010bbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbbbbbbb000000001010101b000001010010111010bbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbbbbbbbb0000001010101bb000000101111111111bbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbbbbbbbbb00000000000bbb000001010010101010bbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbbbbbbb005000000001bbbbb0000010110101010bbbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbbbbb00005d600000bbbbbbb0000000001010101bbbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbbbb000055d667101bbbbbbbb00000011010101bbbbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbbb000015d66670100bbbbbbbb000000000000bbbbbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbb0000105d667110101bbbbbbb00000000001bbbbbbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbb0000010d577101000bbbbbb0000000000101bbbbbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbb00001011511110101bbbbb000015d66710100bbbbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbbb000010101010100bbbbb0000105d667110101bbbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbbbb0010101010101bbbbbb00000105d51101000bbbbbbbb055555577777777777777777777777777777777777777777777777777777777777777770000000bbbbbbb00000010000bbbbbbb00001011111110101bbbbbbbb0555555555555555555aaaaaaaffffff999944442222eeeedddddcccccc1111111000000000000bbbbbbbbb0101010bbbbbbbbbb000010101010100bbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbb0010101010101bbbbbbb055555555555555555555aaaaaaaaffffffff9994442222eedddddddcdcccccc11111100000000000000bbbbbbbbbbbbbbbbbbbbbbbbb00000010000bbbbbbb05555555555555555555555aaaaaafaffffff9999944422eeeedddddddcdcccc1c11110100000000000000bbbbbbbbbbbbbbbbbbbbbbbbbb0101010bbbbbbbbb0555555555555555555555aaaaaaaaffffff9f9994942222eedddddddcdcccccc111555d55510000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0555555555555555555555a5aaaaaafaffff9f9994942422eeeedddddddcdcccc1c115dccccc510000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb055555555555555555555555aaaaaafaffffff999994442222eededddddcdcccccc111cccccccc510000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb05555555555555555555555a5aaaaaafaffff9f9994942222eeeedddddddcdcccc1113ccccccccc55000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb05555555555555555555555a5aaaaaafaffff9f999494222222eeeedddd24eeee50c113cccccccccc55000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb05555555555555555555555a5aaaaaaaaffff9f999494242222eeeedddd4eeeeeeed0111ccccccccccd50000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0555555555555555555555a5a5aaaaaaffffff9f949424222222eeeedd4eeeeeeeeed0d11cccccccccc50000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0555555555555555555555a5a55aaaaafaffff9f999494222222eeeede24eeeeeeeeefd1dd3ccccccccd500000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0555555555555555555555a5a55aaaaaaaffff9f99949422222222eeeed44eeeeeeeeef61ddcccccccccd5000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb055555555555555555555a5a55aaaaaaaffffff9f949422222222eeeeee444eeeeeeefef515cccccc67d50000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbb0555555555555555555a5a5a555aaaaaafaffff9f94942422222222eeeed4444eeeee7fee55513cccc6d5000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbb055555555555555555a5a5a555aaaaaafaffff9f99942422222222e2eeee24e44eeefeeed11153cccdd50000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbb05555555555555555555a55555aaaaaafaffff9f9994942222222222eeeeee44eeeeeeee41153ccccccd500000000000000000bbbbbbbbbbbbbbbbbbbbbbbbb05555555555555555555a55555aaaaaaffffff9f999994242222222222eeeedd24eeeeee4115dccccccccd500000000000000000bbbbbbbbbbbbbbbbbbbbbbbb0555555555555555555a5a555aaaaaaafffff9f999994242222222222eeeeeedd2244442c15dccccccccccd50000000000000000bbbbbbbbbbbbbbbbbbbbbbb0555555555555555555a5a555aaaaaaffafff9f99999424222222222222eeeeee24eeed5cc151ccccccccccc510100000000000000bbbbbbbbbbbbbbbbbbbbb05555555555555555a5a5a555aaaaaaffffff9f99999424222222222222e2eee44eeeeeee5c551dccccccccccd510100000000000000bbbbbbbbbbbbbbbbbbbb0555555555555555a5a5a55aaaaaaaffffff9f9999999424222222222222eee44eeeeeeeee51d11ccccccccccc501010000000000000bbbbbbbbbbbbbbbbbbb05555555555555a5a5a5a5aaaaaaaaffffffff9999999444222222222222e2ee44eeeeeeeeee51d1dcccccccccc5101010100000000000bbbbbbbbbbbbbbbbbb0555555555555a5a5a5aaaaaaaafffffffff9999999944424222222222222ee44eeeeeeeeeefd1ddd3ccccccccc5110101010100000000bbbbbbbbbbbbbbbbbb055555555555a5a5aaaaaaaaaafafffffff999999994942422222222222222e44eeeeeeeeeeff5ddcccccccc6651111110101010100000bbbbbbbbbbbbbbbbbb055555555a5a5aaaaaaaaaaaffffffffff999999999944424222222222222e2444eeeeeeeefffd15dcccccc67d51111111110101010000bbbbbbbbbbbbbbbbbb05a5a5a5a5a5aaaaaaaaaffffffffffff999999999944424222222222222222444eeeeeeef7e7d555dccccccd511111111111110101000bbbbbbbbbbbbbbbbbb0a5a5a5a5aaaaaaaaffffffffffffff999999999994442422222222222222242444eeeee77e77dcccddddddd5111111111111111111100bbbbbbbbbbbbbbbbb0a5aaaaaaaaaaafaffffffffffffff999999999999444442422222222222222f24ee4eeeffef76cccccccccc1c1111111111111111111110bbbbbbbbbbbbbbbb0aaaaaaaafafafffffffff9ffff9999999999999949444242222222222222222e24eeeeeef776cdcccccccccc1c111111111111111111110bbbbbbbbbbbbbbbb0aaaaafafaaafffffffff9f999999999999999494944424222222222222222222ee44eeef776cdcccccccccc1c1c11111111111111111110bbbbbbbbbbbbbbbb0fafafafafafffffff9f9f999999999999999494944424242222222222222222e2eeedeee6dddcdcccccccccc1c1c1111111111111111110bbbbbbbbbbbbbbbb0afafafffffffff9f9f9f99999999999999949444444424222222222222222222e2eeeeeddddddcdcccccccccccc1c1c1111111111111110bbbbbbbbbbbbbbbb0fffffffffff9f9f9f999999999999999494944444442422222222222222222222e2eeeeddd5dddcdcccccccccccc1c1c111111111111110bbbbbbbbbbbbbbb0fffffffffff9f9f9999999999999994949494444444242222222222222222222222e2eeeddddddddcccccccccccccc1c1c111111111111110bbbbbbbbbbbbbb0fffff9ffff9f999999999999999494949494444444242422222222222222222222e2eeeeeddddddcdcccccccccccccc1c1c11111111111110bbbbbbbbbbbbbb0fffffff9f9f99999999999994949494444444444444242222222222222222222222e2eeeeeddddddcdcccccccccccccccc1c1c11111111110bbbbbbbbbbbbbb09f9f9f9f999999999999999494949444444444444424222222222222222222222222e2eeeedddddddcccccccccccccccccc1c1c1111111110bbbbbbbbbbbbbb099f9f9999999999999994949494944444444444442422222222222222222222222222e2eeededdddcdcccccccccccccccccccc1c111111110bbbbbbbbbbbbb099999999999999999999494949444444444444444242222222222222222222222222222e2eeededdddcdcccccccccccccccccccc1c111111110bbbbbbbbbbbb0999999999999999994949494944444444444444424242222222222222222222222222222eeeeeddddddcdcccccccccccccccccccc1c11111110bbbbbbbbbbbb05999999999994449494949494444444444444442424222222222222222222222222222222eeeeeddddddcccccccccccccccccccccc111111110bbbbbbbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbb'

local mymap = {
		["0"] = 0,
		["1"] = 1,
		["2"] = 2,
		["3"] = 3,
		["4"] = 4,
		["5"] = 5,
		["6"] = 6,
		["7"] = 7,
		["8"] = 8,
		["9"] = 9,
		["a"] = 10,
		["b"] = 11,
		["c"] = 12,
		["d"] = 13,
		["e"] = 14,
		["f"] = 15,
		[' '] = nil
	}
	-- Store the original away for safety
	memcpy(original_saved_ss, ssmemloc, 8192)

	-- Overwrite the sprite sheet with picade
	local x = 0
	local y = 0
	for i = 1, #fullss do
		sset(x, y, mymap[fullss[i]])
		-- print(mymap[fullss[i]])
		x += 1
		if x > 127 then
			x = 0
			y += 1
		end
	end
	
	-- Save picade ss to other half of general use
	memcpy(picade_saved_ss, ssmemloc, 8192)
end

function draw_header()
	
	-- local x = 0
	-- local y = 0
	-- for i = 1, #actual do
	-- 	if actual[i] != ' ' then
	-- 		pset(x, y, mymap[actual[i]])
	-- 	end
	-- 	x += 1
	-- 	if x > 127 then
	-- 		x = 0
	-- 		y += 1
	-- 	end
	-- end

	palt(0, false)

	 sspr(17,0,128,21,17, 0)

	 -- Left Bar
	 sspr(18, 0, 14, 96, 18, 0)

	 -- right bar
	 sspr(96, 0, 9, 96, 96, 0)

	 -- bottom console part 1
	 sspr(17, 85, 95, 30, 17, 85)

	 -- bottom console part 2
	 sspr(0, 96, 128, 32, 0, 96)

	

end

function draw_joystick()
  local buttons = {
    ['xunpressed'] = {
      x = 48,
      y = 32,
      width = 16,
      height = 16,
      -- cx = 8,
      -- cy = 21
    },
    ['xpressed'] = {
      x = 64,
      y = 32,
      width = 16,
      height = 16,
      -- cx = 8,
      -- cy = 21
    }
  }
  local controls = {
    ['neutral'] = {
      x = 0,
      y = 0,
      width = 17,
      height = 30,
      cx = 8,
      cy = 21
    },
    ['left'] = {
      x = 105,
      y = 32,
      width = 32,
      height = 26,
      cx = 119,
      cy = 52
    },
    ['right'] = {
      x = 107,
      y = 60,
      width = 32,
      height = 26,
      cx = 115,
      cy = 80
    },
    ['up'] = {
      x = 0,
      y = 32,
      width = 17,
      height = 30,
      cx = 8,
      cy = 55
    },
    ['down'] = {
      x = 0,
      y = 64,
      width = 18,
      height = 28,
      cx = 8,
      cy = 84
    }
  }

  local dir = 'neutral'
  if btn(0) then
    dir = 'left'
  elseif btn(1) then
    dir = 'right'
  elseif btn(2) then
    dir = 'up'
  elseif btn(3) then
    dir = 'down'
  end

  local ctrl = controls[dir]
  palt(11, true)
  palt(0, false)
  local xoff = ctrl.cx - ctrl.x
  local yoff = ctrl.cy - ctrl.y
  sspr(
    ctrl.x, 
    ctrl.y, 
    ctrl.width, 
    ctrl.height,
    38-xoff, 109-yoff)

  local xbut = nil
  if btn(5) then
    xbut = buttons['xpressed']
  else
    xbut = buttons['xunpressed']
  end
  sspr(
    xbut.x,
    xbut.y,
    xbut.width,
    xbut.height,
    58,
    109
    )

  local zbut = nil
  if btn(4) then 
    zbut = buttons['xpressed']
  else
    zbut = buttons['xunpressed']
  end
  sspr(
    zbut.x,
    zbut.y,
    zbut.width,
    zbut.height,
    60,
    97
    )

  palt()
end

firstDrawObject = {
	isFirstDraw = true
}

function _draw()
	if firstDrawObject.isFirstDraw then
		init_spritesheet()
		firstDrawObject.isFirstDraw = false
	end
	local old_draw_state = {}
	for i = 0x5f00, 0x5f3f do
		add(old_draw_state, peek(i))
		-- poke(i, 0)
		-- TODO set draw state to sensible default
	end

	if old_draw then
		-- Restore original sprite sheet
		memcpy(ssmemloc, original_saved_ss, 8192)
		old_draw()

	end
	-- if true then return end
	-- local cornerX, cornerY = 31, 32-8-1
	poke(0x5f54, 0x60)
	palt(0,false)

	-- TODO
	camera()
	-- This makes the minimap
	local minimapY = 21
	sspr(0,0,128,128, 32,minimapY,64,64) 
	-- rectfill(0,0,128,minimapY,13)
	-- rectfill(0,0,17,96,13)
	-- rectfill(105, 18, 128, 92, 13)
	-- rectfill(0,0,128,minimapY,13)
	rectfill(0,0,32,128,13)
	rectfill(96,0,128,128,13)

	palt()

	-- rectfill(0,0,24,128,0)
	-- rectfill(128 - 24-1,0,128,128,0)

	poke(0x5f54, 0x00)
	-- Restore the picade sprite sheet
	memcpy(ssmemloc, picade_saved_ss, 8192)
	draw_header()
	draw_joystick()

	-- for i = 0, 7 do
	-- 	rect(cornerX-i, cornerY-i, cornerX+i+64, cornerY+i+64,7)
	-- end

	for i = 0x5f00, 0x5f3f do
		local nothing = nil
		-- poke(i, old_draw_state[i-0x5f00+1])
		-- add(old_draw_state, peek(i))
	end

	pal(11,13,1)
	-- memcpy(0x8000, 0x6000, 8192)
end
-- End Here

__gfx__
00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000eeeeee5555555555555aa55aa5555555555555000000000000000000000000
00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000eeeee5555555555555aa55aa5555555555555000000000000000000000000
00700700eeeeeeeeeeeeeeeeeeeeee00000eeeeeeeeeeeeeeeeeeeeeeeee0000000eeeee555bb55555555aa55aa5555555555555000000000000000000000000
00077000eeeeeeeeeeeeeeeeeeeee0000000eeeeeeeeeeeeeeeeeeeeeeee0000000eeeee5555bb5555555aa55aa5555555555555000000000000000000000000
00077000eee00007cc70000eeeeee0055500eeeeeeeeeeeeeeeeeeeeeeee0055500eeeee555555b55b555aa55bbbbbb5555b5555000000000000000000000000
00700700ee000557cc700000eeeee0555650eeeee000078870000eeeeeee7777777eeeee5555555bbbbbbbbbbaa5555bb5b55555000000000000000000000000
00000000ee00565777750000eeeee0556550eeee00000788755000eeeeeecc77788eeeee5555555bbb555aa55aa55555bbb55555000000000000000000000000
00000000ee00556777750000eeeee7777777eeee00005777755500eeeeeecc77788eeeee555555555b555aa55aa555555b555555000000000000000000000000
00000000ee00555777750000eeeee88777cceeee00005777765500eeeeee7777777eeeee555555555bb55aa55aa555555bb55555000000000000000000000000
00000000ee00055788700000eeeee88777cceeee00005777756500eeeeee0556550eeeee555555555b5b5aa55aa55555b5b55555000000000000000000000000
00000000eee000078870000eeeeee7777777eeee000007cc755000eeeeee0565550eeeee555555555b55baa55aa5555b55b55555000000000000000000000000
00000000eeeeeeeeeeeeeeeeeeeee0055500eeeee00007cc70000eeeeeee0055500eeeee555555555b555ba55aa555b555b55555000000000000000000000000
00000000eeeeeeeeeeeeeeeeeeeee0000000eeeeeeeeeeeeeeeeeeeeeeee0000000eeeee555555555b555ab55aa5bb5555b55555000000000000000000000000
00000000eeeeeeeeeeeeeeeeeeeee0000000eeeeeeeeeeeeeeeeeeeeeeeee00000eeeeee555555555b555aab5aab555555b55555000000000000000000000000
00000000eeeeeeeeeeeeeeeeeeeee0000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee555555555b555aa5bab5555555b55555000000000000000000000000
00000000eeeeeeeeeeeeeeeeeeeeee00000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee555555555b555aa55ba5555555b55555000000000000000000000000
00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee88888eeeeee5555555555b55aa5babb555555b55555000000000000000000000000
00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee8888888eeeee5555555555b55abb5aa5b55555b55555000000000000000000000000
00000000eeeeeeeeeeeeeeeeeeeeee88888eeeeeeeeeeeeeeeeeeeeeeeee8888888eeeee5555555555b55ba55aa55b5555b55555000000000000000000000000
00000000eeeeeeeeeeeeeeeeeeeee8888888eeeeeeeeeeeeeeeeeeeeeeee8888888eeeee5555555555b5baa55aa555b555b55555000000000000000000000000
00000000eee888822228888eeeeee8855588eeeeeeeeeeeeeeeeeeeeeeee8855588eeeee5555555555b5baa55aa5555b55b55555000000000000000000000000
00000000ee88855222288888eeeee8555658eeeee888822228888eeeeeee2222222eeeee5555555555bb5aa55aa55555bbb55555000000000000000000000000
00000000ee88565222258888eeeee8556558eeee88888222255888eeeeee2222222eeeee555555555bb55aa55aa555555b555555000000000000000000000000
00000000ee88556222258888eeeee2222222eeee88885222255588eeeeee2222222eeeee55555555bbb55aa55aa555bbbb555555000000000000000000000000
00000000ee88555222258888eeeee2222222eeee88885222265588eeeeee2222222eeeee5555555bb5bbbbbbbbbbbb5555b55555000000000000000000000000
00000000ee88855222288888eeeee2222222eeee88885222256588eeeeee8556558eeeee555555b555bb5aa55aa55555555b5555000000000000000000000000
00000000eee888822228888eeeeee2222222eeee88888222255888eeeeee8565558eeeee55555b5555555aa55aa55555555bb555000000000000000000000000
00000000eeeeeeeeeeeeeeeeeeeee8855588eeeee888822228888eeeeeee8855588eeeee5555b55555555aa55aa555555555bb55000000000000000000000000
00000000eeeeeeeeeeeeeeeeeeeee8888888eeeeeeeeeeeeeeeeeeeeeeee8888888eeeee555b555555555aa55aa5555555555b55000000000000000000000000
00000000eeeeeeeeeeeeeeeeeeeee8888888eeeeeeeeeeeeeeeeeeeeeeeee88888eeeeee55bb555555555aa55aa5555555555555000000000000000000000000
00000000eeeeeeeeeeeeeeeeeeeee8888888eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee5555555555555aa55aa5555555555555000000000000000000000000
00000000eeeeeeeeeeeeeeeeeeeeee88888eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee5555555555555aa55aa5555555555555000000000000000000000000
5555555555555aa55aa5555555555555555555555555555555555555555555555555555555555555555555555555555566666666666666666666666666666666
5555555555555aa55aa5555555555555555555555555555555555555555555555555555555555555555555555555555566666666666666666666666666666666
5555555555555aa55aa5555555555555556666655666566666566665666666555555555555555555555555555555555566666666666666666666666666666666
5555555555555aa55aa5555555555555556665665666656666656665566666555555555555555555555555555555555566688888888888888888888888888666
5555555555555aa55aa5555555555555556655555555555555555555555565555555555555555555555555555555555566688888888888888888888888888666
5555555555555aa55aa5555555555555555555555555555555555555555555555555555555555555555555555555555566688222222222222222222222288666
5555555555555aa55aa5555555555555555655555555555555555555555566555555555555555555555555555555555566688222222222222222222222288666
5555555555555aa55aa5555555555555556655555555555555555555555566555555555555555555555555555555555566688222222222222222222222288666
5555555555555aa55aa5555555555555556655555555555555555555555566555555555555555555555555555555555566688222222222222222222222288666
5555555555555aa55aa5555555555555556655555555555555555555555566555555555555555555555555555555555566688222222222222265666222288666
5555555555555aa55aa5555555555555556655555555555555555555555566555555555555555555555555555555555566688222222222222256566552288666
5555555555555aa55aa5555555555555556555555555555555555555555565555555555555555555555555555555555566688222222222222265666252288666
5555555555555aa55aa5555555555555555555555555555555555555555556555555555555555555555555555555555566688222222222222266666252288666
5555555555555aa55aa555555555555555665555555555555555555555555655aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa66688222222222222222222266288666
5555555555555aa55aa555555555555555665555555555555555555555556655aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa66688222222222222222222266288666
5555555555555aa55aa5555555555555556655555555555555555555555566555555555555555555555555555555555566688222222222222222222266288666
5555555555555aa55aa5555555555555556655555555555555555555555566555555555555555555555555555555555566688222222222222222222222288666
5555555555555aa55aa555555555555555665555555555555555555555555555aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa66688222222222222222222222288666
5555555555555aa55aa555555555555555655555555555555555555555555655aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa66688222222222222222222222288666
5555555555555aa55aa5555555555555555655555555555555555555555566555555555555555555555555555555555566688222222222222222222222288666
5555555555555aa55aa5555555555555556655555555555555555555555566555555555555555555555555555555555566688222222222222222222222288666
5555555555555aa55aa5555555555555556655555555555555555555555566555555555555555555555555555555555566688222222222222222222222288666
5555555555555aa55aa5555555555555556655555555555555555555555565555555555555555555555555555555555566688222222222222222222222288666
5555555555555aa55aa5555555555555556555555555555555555555555556555555555555555555555555555555555566688222222222222222222222288666
5555555555555aa55aa5555555555555556555555555555555555555555566555555555555555555555555555555555566688222222222222222222222288666
5555555555555aa55aa5555555555555555655555555555555555555555555555555555555555555555555555555555566688222222222222222222222288666
5555555555555aa55aa5555555555555556655555555555555555555555566555555555555555555555555555555555566688222222222222222222222288666
5555555555555aa55aa5555555555555556655555555555555555555555566555555555555555555555555555555555566688888888888888888888888888666
5555555555555aa55aa5555555555555556666665666656665666665566666555555555555555555555555555555555566688888888888888888888888888666
5555555555555aa55aa5555555555555556666655666656666566666566666555555555555555555555555555555555566666666666666666666666666666666
5555555555555aa55aa5555555555555555555555555555555555555555555555555555555555555555555555555555566666666666666666666666666666666
5555555555555aa55aa5555555555555555555555555555555555555555555555555555555555555555555555555555566666666666666666666666666666666
00000000000000000000000000000000000000000000000000000000c4d4e4f4c4d4e4f4c4d4e4f404142434c4d4e4f4c4d4e4f4c4d4e4f404142434c4d4e4f4
c4d4e4f404142434c4d4e4f4445464748494a4b4445464748494a4b4445464748494a4b444546474c4d4e4f40000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000c5d5e5f5c5d5e5f5c5d5e5f505152535c5d5e5f5c5d5e5f5c5d5e5f505152535c5d5e5f5
c5d5e5f505152535c5d5e5f5455565758595a5b5455565758595a5b5455565758595a5b545556575c5d5e5f50000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000c6d6e6f6c6d6e6f6c6d6e6f606162636c6d6e6f6c6d6e6f6c6d6e6f606162636c6d6e6f6
c6d6e6f606162636c6d6e6f6465666768696a6b6465666768696a6b6465666768696a6b646566676c6d6e6f60000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000c7d7e7f7c7d7e7f7c7d7e7f707172737c7d7e7f7c7d7e7f7c7d7e7f707172737c7d7e7f7
c7d7e7f707172737c7d7e7f7475767778797a7b7475767778797a7b7475767778797a7b747576777c7d7e7f70000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000c4d4e4f4445464748494a4b444546474c4d4e4f4445464748494a4b4445464748494a4b4
44546474445464748494a4b444546474c4d4e4f404142434c4d4e4f404142434c4d4e4f404142434c4d4e4f40000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000c5d5e5f5455565758595a5b545556575c5d5e5f5455565758595a5b5455565758595a5b5
45556575455565758595a5b545556575c5d5e5f505152535c5d5e5f505152535c5d5e5f505152535c5d5e5f50000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000c6d6e6f6465666768696a6b646566676c6d6e6f6465666768696a6b6465666768696a6b6
46566676465666768696a6b646566676c6d6e6f606162636c6d6e6f606162636c6d6e6f606162636c6d6e6f60000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000c7d7e7f7475767778797a7b747576777c7d7e7f7475767778797a7b7475767778797a7b7
47576777475767778797a7b747576777c7d7e7f707172737c7d7e7f707172737c7d7e7f707172737c7d7e7f70000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000c4d4e4f404142434c4d4e4f4445464748494a4b444546474c4d4e4f4c4d4e4f4c4d4e4f4
04142434c4d4e4f4c4d4e4f404142434c4d4e4f404142434c4d4e4f404142434c4d4e4f404142434c4d4e4f40000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000c5d5e5f505152535c5d5e5f5455565758595a5b545556575c5d5e5f5c5d5e5f5c5d5e5f5
05152535c5d5e5f5c5d5e5f505152535c5d5e5f505152535c5d5e5f505152535c5d5e5f505152535c5d5e5f50000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000c6d6e6f606162636c6d6e6f6465666768696a6b646566676c6d6e6f6c6d6e6f6c6d6e6f6
06162636c6d6e6f6c6d6e6f606162636c6d6e6f606162636c6d6e6f606162636c6d6e6f606162636c6d6e6f60000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000c7d7e7f707172737c7d7e7f7475767778797a7b747576777c7d7e7f7c7d7e7f7c7d7e7f7
07172737c7d7e7f7c7d7e7f707172737c7d7e7f707172737c7d7e7f707172737c7d7e7f707172737c7d7e7f70000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000c4d4e4f4445464748494a4b444546474c4d4e4f4445464748494a4b48494a4b48494a4b4
445464748494a4b48494a4b4445464748494a4b4445464748494a4b4445464748494a4b444546474c4d4e4f40000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000c5d5e5f5455565758595a5b545556575c5d5e5f5455565758595a5b58595a5b58595a5b5
455565758595a5b58595a5b5455565758595a5b5455565758595a5b5455565758595a5b545556575c5d5e5f50000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000c6d6e6f6465666768696a6b646566676c6d6e6f6465666768696a6b68696a6b68696a6b6
465666768696a6b68696a6b6465666768696a6b6465666768696a6b6465666768696a6b646566676c6d6e6f60000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000c7d7e7f7475767778797a7b747576777c7d7e7f7475767778797a7b78797a7b78797a7b7
475767778797a7b78797a7b7475767778797a7b7475767778797a7b7475767778797a7b747576777c7d7e7f70000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4
c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f40000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5
c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f50000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6
c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f60000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7
c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f70000000000000000000000000000000000000000
__label__
55555555555555555555555555555555555555555555555555555555555566666556665666665666656666665566666666666666666666666666666666666666
55555555555555555555555555555555555555555555555555555555555566656656666566666566655666665566688888888888888888888888888666666888
55555555555555555555555555555555555555555555555555555555555566555555555555555555555555655566688888888888888888888888888666666888
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555566688222222222222222222222288666666882
55555555555555555555555555555555555555555555555555555555555556555555555555555555555555665566688222222222222222222222288666666882
55555555555555555555555555555555555555555555555555555555555566555555555555555555555555665566688222222222222222222222288666666882
55555555555555555555555555555555555555555555555555555555555566555555555555555555555555665566688222222222222222222222288666666882
55555555555555555555555555555555555555555555555555555555555566555555555555555555555555665566688222222222222265666222288666666882
55555555555555555555555555555555555555555555555555555555555566555555555555555555555555665566688222222222222256566552288666666882
55555555555555555555555555555555555555555555555555555555555565555555555555555555555555655566688222222222222265666252288666666882
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555565566688222222222222266666252288666666882
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa5566555555555555555555555555565566688222222222222222222266288666666882
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa5566555555555555555555555555665566688222222222222222222266288666666882
55555555555555555555555555555555555555555555555555555555555566555555555555555555555555665566688222222222222222222266288666666882
55555555555555555555555555555555555555555555555555555555555566555555555555555555555555665566688222222222222222222222288666666882
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa5566555555555555555555555555555566688222222222222222222222288666666882
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa5565555555555555555555555555565566688222222222222222222222288666666882
55555555555555555555555555555555555555555555555555555555555556555555555555555555555555665566688222222222222222222222288666666882
55555555555555555555555555555555555555555555555555555555555566555555555555555555555555665566688222222222222222222222288666666882
55555555555555555555555555555555555555555555555555555555555566555555555555555555555555665566688222222222222222222222288666666882
55555555555555555555555555555555555555555555555555555555555566555555555555555555555555655566688222222222222222222222288666666882
55555555555555555555555555555555555555555555555555555555555565555555555555555555555555565566688222222222222222222222288666666882
55555555555555555555555555555555555555555555555555555555555565555555555555555555555555665566688222222222222222222222288666666882
55555555555555555555555555555555555555555555555555555555555556555555555555555555555555555566688222222222222222222222288666666882
55555555555555555555555555555555555555555555555555555555555566555555555555555555555555665566688222222222222222222222288666666882
55555555555555555555555555555555555555555555555555555555555566555555555555555555555555665566688888888888888888888888888666666888
55555555555555555555555555555555555555555555555555555555555566666656666566656666655666665566688888888888888888888888888666666888
55555555555555555555555555555555555555555555555555555555555566666556666566665666665666665566666666666666666666666666666666666666
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555566666666666666666666666666666666666666
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555566666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666665555555555555aa55aa555555555555566666666666666666666666666666666555555
66666666666666666666666666666666666666666666666666666666665555555555555aa55aa555555555555566666666666666666666666666666666555555
66666666666666666666666666666666666666666666666666666666665555555555555aa55aa555555555555566666666666666666666666666666666556666
88888888888888888888888666666888888888888888888888888886665555555555555aa55aa555555555555566688888888888888888888888888666556665
88888888888888888888888666666888888888888888888888888886665555555555555aa55aa555555555555566688888888888888888888888888666556655
22222222222222222222288666666882222222222222222222222886665555555555555aa55aa555555555555566688222222222222222222222288666555555
22222222222222222222288666666882222222222222222222222886665555555555555aa55aa555555555555566688222222222222222222222288666555655
22222222222222222222288666666882222222222222222222222886665555555555555aa55aa555555555555566688222222222222222222222288666556655
22222222222222222222288666666882222222222222222222222886665555555555555aa55aa555555555555566688222222222222222222222288666556655
22222222222265666222288666666882222222222222656662222886665555555555555aa55aa555555555555566688222222222222265666222288666556655
22222222222256566552288666666882222222222222565665522886665555555555555aa55aa555555555555566688222222222222256566552288666556655
22222222222265666252288666666882222222222222656662522886665555555555555aa55aa555555555555566688222222222222265666252288666556555
22222222222266666252288666666882222222222222666662522886665555555555555aa55aa555555555555566688222222222222266666252288666555555
22222222222222222266288666666882222222222222222222662886665555555555555aa55aa555555555555566688222222222222222222266288666556655
22222222222222222266288666666882222222222222222222662886665555555555555aa55aa555555555555566688222222222222222222266288666556655
22222222222222222266288666666882222222222222222222662886665555555555555aa55aa555555555555566688222222222222222222266288666556655
22222222222222222222288666666882222222222222222222222886665555555555555aa55aa555555555555566688222222222222222222222288666556655
22222222222222222222288666666882222222222222222222222886665555555555555aa55aa555555555555566688222222222222222222222288666556655
22222222222222222222288666666882222222222222222222222886665555555555555aa55aa555555555555566688222222222222222222222288666556555
22222222222222222222288666666882222222222222222222222886665555555555555aa55aa555555555555566688222222222222222222222288666555655
22222222222222222222288666666882222222222222222222222886665555555555555aa55aa555555555555566688222222222222222222222288666556655
22222222222222222222288666666882222222222222222222222886665555555555555aa55aa555555555555566688222222222222222222222288666556655
22222222222222222222288666666882222222222222222222222886665555555555555aa55aa555555555555566688222222222222222222222288666556655
22222222222222222222288666666882222222222222222222222886665555555555555aa55aa555555555555566688222222222222222222222288666556555
22222222222222222222288666666882222222222222222222222886665555555555555aa55aa555555555555566688222222222222222222222288666556555
22222222222222222222288666666882222222222222222222222886665555555555555aa55aa555555555555566688222222222222222222222288666555655
22222222222222222222288666666882222222222222222222222886665555555555555aa55aa555555555555566688222222222222222222222288666556655
88888888888888888888888666666888888888888888888888888886665555555555555aa55aa555555555555566688888888888888888888888888666556655
88888888888888888888888666666888888888888888888888888886665555555555555aa55aa555555555555566688888888888888888888888888666556666
66666666666666666666666666666666666666666666666666666666665555555555555aa55aa555555555555566666666666666666666666666666666556666
66666666666666666666666666666666666666666666666666666666665555555555555aa55aa555555555555566666666666666666666666666666666555555
66666666666666666666666666666666666666666666666666666666600007887000055aa55aa555555555555566666666666666666666666666666666555555
55555555555555555555555555555555555555555555555555555555000007887550005555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555000057777555005555555555555555555555555555555555555555555555555555555555
65566656666656666566666655555555555555555555555555555555000057777655005666665666656666665555555555555555555555555555555555556666
66566665666665666556666655555555555555555555555555555555000057777565006566666566655666665555555555555555555555555555555555556665
55555555555555555555556555555555555555555555555555555555000007cc7550005555555555555555655555555555555555555555555555555555556655
55555555555555555555555555555555555555555555555555555555500007cc7000055555555555555555555555888822228888555555555555555555555555
55555555555555555555556655555555555555555555555555555555555556555555555555555555555555665558888822225588855555555555555555555655
55555555555555555555556655555555555555555555555555555555555566555555555555555555555555665558888522225558855555555555555555556655
55555555555555555555556655555555555555555555555555555555555566555555555555555555555555665558888522226558855555555555555555556655
55555555555555555555556655555555555555555555555555555555555566555555555555555555555555665558888522225658855555555555555555556655
55555555555555555555556655555555555555555555555555555555555566555555555555555555555555665558888822225588855555555555555555556655
55555555555555555555556555555555555555555555555555555555555565555555555555555555555555655555888822228888555555555555555555556555
55555555555555555555555655555555555555555555555555555555555555555555555555555555555555565555555555555555555555555555555555555555
55555555555555555555555655aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa55665555555555555555555555555655aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa556655
55555555555555555555556655aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa55665555555555555555555555556655aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa556655
55555555555555555555556655555555555555555555555555555555555566555555555555555555555555665555555555555555555555555555555555556655
55555555555555555555556655555555555555555555555555555555555566555555555555555555555555665555555555555555555555555555555555556655
55555555555555555555555555aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa55665555555555555555555555555555aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa556655
55555555555555555555555655aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa55655555555555555555555555555655aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa556555
55555555555555555555556655555555555555555555555555555555555556555555555555555555555555665555555555555555555555555555555555555655
55555555555555555555556655555555555555555555555555555555555566555555555555555555555555665555555555555555555555555555555555556655
55555555555555555555556655555555555555555555555555555555555566555555555555555555555555665555555555555555555555555555555555556655
55555555555555555555556555555555555555555555555555555555555566555555555555555555555555655555555555555555555555555555555555556655
55555555555555555555555655555555555555555555555555555555555565555555555555555555555555565555555555555555555555555555555555556555
55555555555555555555556655555555555555555555555555555555555565555555555555555555555555665555555555555555555555555555555555556555
55555555555555555555555555555555555555555555555555555555555556555555555555555555555555555555555555555555555555555555555555555655
55555555555555555555556655555555555555555555555555555555555566555555555555555555555555665555555555555555555555555555555555556655
55555555555555555555556655555555555555555555555555555555555566555555555555555555555555665555555555555555555555555555555555556655
66566665666566666556666655555555555555555555555555555555555566666656666566656666655666665555555555555555555555555555555555556666
65566665666656666656666655555555555555555555555555555555555566666556666566665666665666665555555555555555555555555555555555556666
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5555555aa55aa5555555555555666666666666666666666666666666665555555555555aa55aa555555555555566666666666666666666666666666666555555
5555555aa55aa5555555555555666666666666666666666666666666665555555555555aa55aa555555555555566666666666666666666666666666666555555
5555555aa55aa5555555555555666666666666666666666666666666665555555555555aa55aa555555555555566666666666666666666666666666666555555
5555555aa55aa5555555555555666888888888888888888888888886665555555555555aa55aa555555555555566688888888888888888888888888666555555
5555555aa55aa5555555555555666888888888888888888888888886665555555555555aa55aa555555555555566688888888888888888888888888666555555
5555555aa55aa5555555555555666882222222222222222222222886665555555555555aa55aa555555555555566688222222222222222222222288666555555
5555555aa55aa5555555555555666882222222222222222222222886665555555555555aa55aa555555555555566688222222222222222222222288666555555
5555555aa55aa5555555555555666882222222222222222222222886665555555555555aa55aa555555555555566688222222222222222222222288666555555
5555555aa55aa5555555555555666882222222222222222222222886665555555555555aa55aa555555555555566688222222222222222222222288666555555
5555555aa55aa5555555555555666882222222222222656662222886665555555555555aa55aa555555555555566688222222222222265666222288666555555
5555555aa55aa5555555555555666882222222222222565665522886665555555555555aa55aa555555555555566688222222222222256566552288666555555
5555555aa55aa5555555555555666882222222222222656662522886665555555555555aa55aa555555555555566688222222222222265666252288666555555
5555555aa55aa5555555555555666882222222222222666662522886665555555555555aa55aa555555555555566688222222222222266666252288666555555
5555555aa55aa5555555555555666882222222222222222222662886665555555555555aa55aa555555555555566688222222222222222222266288666555555
5555555aa55aa5555555555555666882222222222222222222662886665555555555555aa55aa555555555555566688222222222222222222266288666555555
5555555aa55aa5555555555555666882222222222222222222662886665555555555555aa55aa555555555555566688222222222222222222266288666555555
5555555aa55aa5555555555555666882222222222222222222222886665555555555555aa55aa555555555555566688222222222222222222222288666555555
5555555aa55aa5555555555555666882222222222222222222222886665555555555555aa55aa555555555555566688222222222222222222222288666555555
5555555aa55aa5555555555555666882222222222222222222222886665555555555555aa55aa555555555555566688222222222222222222222288666555555
5555555aa55aa5555555555555666882222222222222222222222886665555555555555aa55aa555555555555566688222222222222222222222288666555555
5555555aa55aa5555555555555666882222222222222222222222886665555555555555aa55aa555555555555566688222222222222222222222288666555555
5555555aa55aa5555555555555666882222222222222222222222886665555555555555aa55aa555555555555566688222222222222222222222288666555555
5555555aa55aa5555555555555666882222222222222222222222886665555555555555aa55aa555555555555566688222222222222222222222288666555555
5555555aa55aa5555555555555666882222222222222222222222886665555555555555aa55aa555555555555566688222222222222222222222288666555555
5555555aa55aa5555555555555666882222222222222222222222886665555555555555aa55aa555555555555566688222222222222222222222288666555555
5555555aa55aa5555555555555666882222222222222222222222886665555555555555aa55aa555555555555566688222222222222222222222288666555555
5555555aa55aa5555555555555666882222222222222222222222886665555555555555aa55aa555555555555566688222222222222222222222288666555555
5555555aa55aa5555555555555666888888888888888888888888886665555555555555aa55aa555555555555566688888888888888888888888888666555555
5555555aa55aa5555555555555666888888888888888888888888886665555555555555aa55aa555555555555566688888888888888888888888888666555555
5555555aa55aa5555555555555666666666666666666666666666666665555555555555aa55aa555555555555566666666666666666666666666666666555555
5555555aa55aa5555555555555666666666666666666666666666666665555555555555aa55aa555555555555566666666666666666666666666666666555555
5555555aa55aa5555555555555666666666666666666666666666666665555555555555aa55aa555555555555566666666666666666666666666666666555555
55555555555555555555555555666666666666666666666666666666665555555555555aa55aa555555555555566666666666666666666666666666666555555
55555555555555555555555555666666666666666666666666666666665555555555555aa55aa555555555555566666666666666666666666666666666555555

__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010101020202020404040408080808010101010202020204040404080808080101010102020202040404040808080801010101020202020404040408080808
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
00000000090a0b0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000191a1b1c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000292a2b2c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000393a3b3c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000090a0b0c00000000000000000000000000000000000000004c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f0000000000000000000000000000000000000000
00000000191a1b1c00000000000000000000000000000000000000005c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f0000000000000000000000000000000000000000
00000000292a2b2c00000000000000000000000000000000000000006c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f0000000000000000000000000000000000000000
00000000393a3b3c00000000000000000000000000000000000000007c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f0000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000004c4d4e4f4445464748494a4b48494a4b48494a4b4445464748494a4b48494a4b48494a4b444546474c4d4e4f4c4d4e4f4445464748494a4b48494a4b48494a4b4445464748494a4b444546474c4d4e4f0000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000005c5d5e5f5455565758595a5b58595a5b58595a5b5455565758595a5b58595a5b58595a5b545556575c5d5e5f5c5d5e5f5455565758595a5b58595a5b58595a5b5455565758595a5b545556575c5d5e5f0000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000006c6d6e6f6465666768696a6b68696a6b68696a6b6465666768696a6b68696a6b68696a6b646566676c6d6e6f6c6d6e6f6465666768696a6b68696a6b68696a6b6465666768696a6b646566676c6d6e6f0000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000007c7d7e7f7475767778797a7b78797a7b78797a7b7475767778797a7b78797a7b78797a7b747576777c7d7e7f7c7d7e7f7475767778797a7b78797a7b78797a7b7475767778797a7b747576777c7d7e7f0000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000004c4d4e4f404142434c4d4e4f4c4d4e4f4c4d4e4f404142434c4d4e4f4c4d4e4f4c4d4e4f4445464748494a4b48494a4b444546474c4d4e4f4c4d4e4f4c4d4e4f404142434c4d4e4f404142434c4d4e4f0000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000005c5d5e5f505152535c5d5e5f5c5d5e5f5c5d5e5f505152535c5d5e5f5c5d5e5f5c5d5e5f5455565758595a5b58595a5b545556575c5d5e5f5c5d5e5f5c5d5e5f505152535c5d5e5f505152535c5d5e5f0000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000006c6d6e6f606162636c6d6e6f6c6d6e6f6c6d6e6f606162636c6d6e6f6c6d6e6f6c6d6e6f6465666768696a6b68696a6b646566676c6d6e6f6c6d6e6f6c6d6e6f606162636c6d6e6f606162636c6d6e6f0000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000007c7d7e7f707172737c7d7e7f7c7d7e7f7c7d7e7f707172737c7d7e7f7c7d7e7f7c7d7e7f7475767778797a7b78797a7b747576777c7d7e7f7c7d7e7f7c7d7e7f707172737c7d7e7f707172737c7d7e7f0000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000004c4d4e4f404142434c4d4e4f4c4d4e4f4c4d4e4f404142434c4d4e4f4c4d4e4f4c4d4e4f404142434c4d4e4f4c4d4e4f404142434c4d4e4f4445464748494a4b4445464748494a4b444546474c4d4e4f0000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000005c5d5e5f505152535c5d5e5f5c5d5e5f5c5d5e5f505152535c5d5e5f5c5d5e5f5c5d5e5f505152535c5d5e5f5c5d5e5f505152535c5d5e5f5455565758595a5b5455565758595a5b545556575c5d5e5f0000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000006c6d6e6f606162636c6d6e6f6c6d6e6f6c6d6e6f606162636c6d6e6f6c6d6e6f6c6d6e6f606162636c6d6e6f6c6d6e6f606162636c6d6e6f6465666768696a6b6465666768696a6b646566676c6d6e6f0000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000007c7d7e7f707172737c7d7e7f7c7d7e7f7c7d7e7f707172737c7d7e7f7c7d7e7f7c7d7e7f707172737c7d7e7f7c7d7e7f707172737c7d7e7f7475767778797a7b7475767778797a7b747576777c7d7e7f0000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000004c4d4e4f4445464748494a4b4445464748494a4b4445464748494a4b444546474c4d4e4f444546474445464748494a4b4445464748494a4b444546474c4d4e4f404142434c4d4e4f404142434c4d4e4f0000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000005c5d5e5f5455565758595a5b5455565758595a5b5455565758595a5b545556575c5d5e5f545556575455565758595a5b5455565758595a5b545556575c5d5e5f505152535c5d5e5f505152535c5d5e5f0000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000006c6d6e6f6465666768696a6b6465666768696a6b6465666768696a6b646566676c6d6e6f646566676465666768696a6b6465666768696a6b646566676c6d6e6f606162636c6d6e6f606162636c6d6e6f0000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000007c7d7e7f7475767778797a7b7475767778797a7b7475767778797a7b747576777c7d7e7f747576777475767778797a7b7475767778797a7b747576777c7d7e7f707172737c7d7e7f707172737c7d7e7f0000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000004c4d4e4f404142434c4d4e4f404142434c4d4e4f404142434c4d4e4f404142434c4d4e4f4c4d4e4f404142434c4d4e4f404142434c4d4e4f404142434c4d4e4f4445464748494a4b444546474c4d4e4f0000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000005c5d5e5f505152535c5d5e5f505152535c5d5e5f505152535c5d5e5f505152535c5d5e5f5c5d5e5f505152535c5d5e5f505152535c5d5e5f505152535c5d5e5f5455565758595a5b545556575c5d5e5f0000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000006c6d6e6f606162636c6d6e6f606162636c6d6e6f606162636c6d6e6f606162636c6d6e6f6c6d6e6f606162636c6d6e6f606162636c6d6e6f606162636c6d6e6f6465666768696a6b646566676c6d6e6f0000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000007c7d7e7f707172737c7d7e7f707172737c7d7e7f707172737c7d7e7f707172737c7d7e7f7c7d7e7f707172737c7d7e7f707172737c7d7e7f707172737c7d7e7f7475767778797a7b747576777c7d7e7f0000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000004c4d4e4f4445464748494a4b4445464748494a4b444546474c4d4e4f4445464748494a4b48494a4b444546474c4d4e4f404142434c4d4e4f404142434c4d4e4f404142434c4d4e4f404142434c4d4e4f0000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000005c5d5e5f5455565758595a5b5455565758595a5b545556575c5d5e5f5455565758595a5b58595a5b545556575c5d5e5f505152535c5d5e5f505152535c5d5e5f505152535c5d5e5f505152535c5d5e5f0000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000006c6d6e6f6465666768696a6b6465666768696a6b646566676c6d6e6f6465666768696a6b68696a6b646566676c6d6e6f606162636c6d6e6f606162636c6d6e6f606162636c6d6e6f606162636c6d6e6f0000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000007c7d7e7f7475767778797a7b7475767778797a7b747576777c7d7e7f7475767778797a7b78797a7b747576777c7d7e7f707172737c7d7e7f707172737c7d7e7f707172737c7d7e7f707172737c7d7e7f0000000000000000000000000000000000000000
__sfx__
003d00200a6100f611156111c6112c6113161131611236111b6110d6110d6110c6110b6110a621096110861107611096110b6110161106611076110f611186111c61125611256111c61116611126110d61109611
0008080a1307014070180701806018050180401803018020180141801500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010b0809245701d5701c5701c5601c5501c5401c5301c5201c5100050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
0004000031735317302f7202c7202a72028720267252572024720217201e7201c7251a720187201672013720107200e7200672004720007000a7000a7000a7050a70012700127050070000700007000c70000700
010300280000000000246250000000000000000000000000246150000000000000000c30018625000000000018000180002430018000180001800024300180001800018000000000000000000000000000000000
011000010017000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0504000026620236201f6201762011620106201162011610126101461018600186000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c000000000000000000000000000000000
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
game_name: Pursuit in Progress
# Leave blank to use game-name
game_slug: 
jam_info:
  - jam_name: TriJam
    jam_number: 119
    jam_url: null
    jam_theme: Law and Order
tagline: Don't let the perp escape!
time_left: '0:11:48'
develop_time: '3h 1m 3s'
description: |
  Catch the perpetrator! Don't crash into any buildings and don't let the perp out of your sight!  
controls:
  - inputs: [ARROW_KEYS]
    desc: turn police car
  - inputs: [X]
    desc: restart the game when the game ends
  - inputs: [P]
    desc: Pause menu. Allows selecting 2-player mode
  - inputs: [ESDF]
    desc: turn the perp's car (in 2 player mode)
hints: |
  * Stay on the perp's tail and you will slowly build speed
  * You don't have to follow the perp's every move - see if 
  you can anticipate their actions and head them off
      * Don't let them get too far away though, or they will escape!
acknowledgements: |
  Music is from Gruber's [Pico-8 Tunes Vol. 2](https://www.lexaloffle.com/bbs/?pid=picotunes2)

  * Track 7 - Flight of Icarus (chase music)
  * Track 4 - Morning Shower (victory music)

  Licensed under [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/)
to_do: []
version: 0.2.0
img_alt: Aerial view of city blocks with police car chasing a red car
about_extra: ''
number_players: [1,2]
__meta:cart_info_end__
