pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
--toxic toads                    v0.2.0
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

function _init()
	music(30)
	gs = {
		isGameOver = false,
		gameOverState = nil,
		startTime = t(),
		endTime = nil,
		currentAnimation = nil,
		frogs = {},
		poisonChain = {},
		dim = 8,
		cursor = vec2(4, 7),
		boundaryCursor = vec2(4, 7),
		getSelected = function(self)
			for frog in all(self.frogs) do
				if frog:isHighlighted() then
					return frog
				end
			end
		end,
		getFrogAt = function(self, pos, overrideBoundary)
			for frog in all(self.frogs) do
				if frog.pos == pos and (overrideBoundary or not frog:isBoundary()) then
					return frog
				end
			end
		end,
		checkSuccess = function(self)
			for frog in all(gs.frogs) do
				if not frog:isBoundary() and
				 not frog.isPoisoned then
					return false
				end
			end
			return true
		end
	}

	populateFrogs()
	-- gs.frogs[29].isHighlighted = true
end

function winPuzzle()
	sfx(1)
	-- Create animation???
	gs.currentAnimation = cocreate(function()
		for i = 1, 10 do
			yield()
		end
		gs.isGameOver = true
		gs.gameOverState = 'win'
	end)
end

function failPuzzle()
	gs.currentAnimation = cocreate(function()
		sfx(0)

		-- for frog in all(gs.poisonChain) do
		for i = #gs.poisonChain, 1, -1 do
			local frog = gs.poisonChain[i]
			if not frog:isBoundary() then
				frog.isPoisoned = false
			end
			yield()
			yield()
			yield()
		end
		gs.poisonChain = {}
	end)

end

function populateFrogs()
	for x = 0, gs.dim-1 do
		for y = 0, gs.dim-1 do
			local pos = vec2(x,y)
			if pos == vec2(3, 2) or
				pos == vec2(5, 3) or
				pos == vec2(6, 1) then
					-- Nothing				
			else
				if isBoundary(pos) then
					local facing = 0
					if pos.x == 0 then
						facing = 2 -- right
					elseif pos.x == gs.dim-1 then
						facing = 0 --left
					elseif pos.y == 0 then
						facing = 3
					elseif pos.y == gs.dim-1 then
						facing = 1
					end

					add(gs.frogs, makeFrog(
						x,
						y,
						facing,
						true
						))
				else
					add(gs.frogs, makeFrog(
						x,
						y,
						rnd({0, 1, 2, 3})
						))
				end
			end
		end
	end
end

function getFacingOffset(facing)
	if facing == 0 then
		return vec2(-1, 0)
	elseif facing == 1 then
		return vec2(0, -1)
	elseif facing == 2 then
		return vec2(1, 0)
	else
		return vec2(0, 1)
	end
end

function isBoundary(v)
	return v.x == 0 or v.x == gs.dim -1
				or v.y == 0 or v.y == gs.dim -1
end

function makeFrog(x, y, facing, isPoisoned)
	return {
		isBoundary = function(self)
			return isBoundary(self.pos)
		end,
		getUpperLeft = function(self)
			local offset = vec2(0, 0)
			return self.pos * 16 + offset
		end,
		pos = vec2(x, y),
		-- Note, this does not follow dirs convention
		facing = facing,
		isPoisoned = isPoisoned, --rnd() < 0.5,
		isHighlighted = function(self)
			return self.pos == gs.cursor
		end,
		getFacing = function(self)
			return self.pos + getFacingOffset(self.facing)
		end,
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

function vec2(x, y)
	local ret = {
		x = x,
		y = y,
		clone = function(self)
			return vec2(self.x, self.y)
		end,
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

function cursorIsValid(cursor)
	if 0 <= cursor.x and cursor.x < gs.dim and
		0 <= cursor.y and cursor.y < gs.dim then
			-- TODO also check vacant spots
			-- ...maybe not necessary
		if not isBoundary(cursor) then
			return true
		else
			return (gs.cursor == gs.boundaryCursor)
				or (cursor == gs.boundaryCursor)
		end
	end
	return false
end
-- function modularAdd(x, )
function acceptInput()
	local cursor = gs.cursor:clone()
	if btnp(dirs.left) then
		cursor.x -= 1
	elseif btnp(dirs.right) then
		cursor.x += 1
	elseif btnp(dirs.up) then
		cursor.y -= 1
	elseif btnp(dirs.down) then
		cursor.y += 1
	end
	if cursorIsValid(cursor) then
		if gs.cursor == gs.boundaryCursor and isBoundary(cursor) then
			gs.boundaryCursor = cursor
		end
		gs.cursor = cursor
	end

	local selectedFrog = gs:getSelected()
	if selectedFrog != nil then
		if selectedFrog:isBoundary() then
			if btnp(dirs.x) then
				createAnimation(selectedFrog)
			end
		else
			if btnp(dirs.z) then
				-- TODO get rid of this
				selectedFrog.facing = (selectedFrog.facing - 1) % 4
			elseif btnp(dirs.x) then
				selectedFrog.facing = (selectedFrog.facing + 1) % 4
			end
		end
	end
end

function createAnimation(frog)
	gs.currentAnimation = cocreate(function()

		-- local upperLeft = frog:getUpperLeft()
		-- Tongue
		local spriteNumber = 72 + frog.facing * 2
		for i = 1, 14, 3 do
			local upperLeft = frog:getUpperLeft() + getFacingOffset(frog.facing) * i
			spr(spriteNumber, upperLeft.x, upperLeft.y, 2, 2)
			drawFrog(frog)
		drawCursor()
			yield()
		end

		local otherFrog = gs:getFrogAt(frog:getFacing())

		local isFailed = false
		-- Check failure here
		if otherFrog == nil then
			isFailed = true
 		elseif otherFrog.isPoisoned then
 			isFailed = true
 		else
			otherFrog.isPoisoned = true
			add(gs.poisonChain, otherFrog)
		end

		for i = 14, 1, -3 do
			local upperLeft = frog:getUpperLeft() + getFacingOffset(frog.facing) * i
			spr(spriteNumber, upperLeft.x, upperLeft.y, 2, 2)
			drawFrog(frog)
		drawCursor()
			yield()
		end



		if isFailed then
			failPuzzle()
			return
		elseif gs:checkSuccess() then
			winPuzzle()
			return
		end



		createAnimation(otherFrog)
    end)
end

function _update()
	if gs.isGameOver then
		if gs.endTime == nil then
			gs.endTime = t()
		end
		-- Restart
		if btnp(dirs.x) then
			_init()
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

end

function drawGameOverWin()
	print('')
	print(' you won!')
	print('')
	print(' press ❎ to play again')
end

function drawGameOverLose()

end

function drawFrog(frog, drawHighlight, drawBoundary)
	local spriteNumber = 64
	if frog.isPoisoned then
		spriteNumber = 96
	end
	spriteNumber += frog.facing * 2

	if frog:isBoundary() and not drawBoundary then
		return
	end

	local upperLeft = frog:getUpperLeft()
	palt(0, false)
	palt(15, true)
	spr(spriteNumber, 
		upperLeft.x,
		upperLeft.y,
		2, 
		2
		)
	palt()
	-- if frog:isHighlighted() and drawHighlight then
	-- 	upperLeft -= vec2(1,1)
	-- 	rect(upperLeft.x, upperLeft.y,
	-- 		upperLeft.x + 16, upperLeft.y + 16, 7)
	-- end
end

function drawFrogs()
	for frog in all(gs.frogs) do
		drawFrog(frog, true)
	end
end

-- function doDrawHighlight()
-- 	-- makeFrog()
-- end

function drawCursor()
	local upperLeft = gs.cursor * 16
	rect(upperLeft.x, upperLeft.y, upperLeft.x+16, upperLeft.y +16, 7)

	local frog = gs:getFrogAt(gs.boundaryCursor, true)
	if frog != nil then
		drawFrog(frog, nil, true)
	end
end

function _draw()
	cls(1)
	if gs.isGameOver then
		if gs.gameOverState == gameOverWin then
			drawGameOverWin()
		else
			drawGameOverLose()
		end
		return
	end

	drawFrogs()

	-- doDrawHighlight()
	drawCursor()


	if hasAnimation() then
		local active, exception = coresume(gs.currentAnimation)
		if exception then
			stop(trace(gs.currentAnimation, exception))
		end

		return
	end

	-- Draw
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000003330000330000000bbbbbbbb0000000bbb00000bb000000bbb00000bb00000000000000000000000000000000000000000000000000000000000
0070070000033b330033330000bbbbbbbbbbbb00000bbbb333bbbb00000bbbb882bbbb0000000000000000000000000000000000000000000000000000000000
0007700000033b33303133000bbb33333333bbb000b33b33333b330000b6cb88882bc1000000000ee00000000000000000000000000000000000000000000000
0007700000333133331133300bbb3333333333bb00b33333333333b000bcce888888c1b00000000ee00000000000000000000000000000000000000000000000
0070070000333113331b333000bb3333333333bb0bb33300300333b00bb6c8008008c1b0000000eeee0000000000000000000000000000000000000000000000
000000000033331333bb3330000bbb53333335bb0bbb337037033bb00bbbe87087082bb0000000eeee0000000000000000000000000000000000000000000000
000000000033333333b333300000b335333353bb0bbb333333333bb00bbb888888882bb0000000eeee0000000000000000000000000000000000000000000000
000000000033331331133330000bb333333333bb0bbb333333333bb00bbbe88888888bb00000000ee00000000000000000000000000000000000000000000000
00000000003333133133330000bbb553333355bb0bbb533333335bb00bbb588888825bb00000000ee00000000000000000000000000000000000000000000000
0000000000333313333333000bbbb335333533bb0bbb353333353bb00bbbc5e88825cbb00000000ee00000000000000000000000000000000000000000000000
0000000000033313333333000bbbb33333333bb00bbb335333533bb00bbbcc58885ccbb00000000ee00000000000000000000000000000000000000000000000
0000000000003313333330000bbbbb3333333b0000bb333333333b0000bb6ccc8ccc1b000000000ee00000000000000000000000000000000000000000000000
00000000000003b333330000000bbbb3333bb000000bb3333333bb00000bb6cc8cc1bb000000000ee00000000000000000000000000000000000000000000000
00000000000000000000000000000bbbbbbb00000000bbbbbbbbb0000000bbbbbbbbb0000000000ee00000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000bbbbbbb000000000bbbbbbb00000000000ee00000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffffffffffffffffffffffffffffffffffffffffbbbbbbbfffff0000000000000000000000000000000000000000000000000000000ee0000000
ffffbbbbbbbbfffffffbbbfffffbbfffffffbbbbbbbffffffffbbbbbbbbbffff0000000000000000000000000000000000000000000000000000000ee0000000
ffb333bbbbbbbbfffffbbbb333bbbbfffffbbbbbbbbbbfffffbb3333333bbfff0000000000000000000000000000000000000000000000000000000ee0000000
fbb3333335333bbfffb33b33333b33ffffbbbbbbbb333bbfffb333333333bbff00000000000000000000000ee000000000000000000000000000000ee0000000
fbbb3333335333bbffb33333333333bffbb3335333333bbffbb335333533bbbf00000000000000000000000ee000000000000000000000000000000ee0000000
ffb33003333533bbfbb33300300333bfbb3335333333bbbffbb353333353bbbf0000000000000000000000eeee00000000000000000000000000000ee0000000
ff333073333333bbfbbb337037033bbfbb33533337033bfffbb533333335bbbf00000eee00000000000000eeee00000000000000eee000000000000ee0000000
ff333333333333bbfbbb333333333bbfbb333333300333fffbb333333333bbbf000eeeeeeeeeeeee000000eeee000000eeeeeeeeeeeee0000000000ee0000000
ff333003333333bbfbbb333333333bbfbb333333333333fffbb333333333bbbf000eeeeeeeeeeeee0000000ee0000000eeeeeeeeeeeee000000000eeee000000
ffb33073333533bbfbbb533333335bbfbb333333370333fffbb330730733bbbf00000eee000000000000000ee000000000000000eee00000000000eeee000000
fbbb3333335333bbfbbb353333353bbfbb33533330033bfffb33300300333bbf00000000000000000000000ee00000000000000000000000000000eeee000000
fbb3333335333bbffbbb335333533bbfbb3335333333bbbffb33333333333bff00000000000000000000000ee000000000000000000000000000000ee0000000
fbb333bbbbbbbbffffbb333333333bfffbb3335333333bbfff33b33333b33bff00000000000000000000000ee000000000000000000000000000000ee0000000
fffbbbbbbbbbbffffffbb3333333bbffffbbbbbbbb333bffffbbbb333bbbbfff00000000000000000000000ee000000000000000000000000000000000000000
fffffbbbbbbbffffffffbbbbbbbbbfffffffbbbbbbbbfffffffbbfffffbbbfff00000000000000000000000ee000000000000000000000000000000000000000
fffffffffffffffffffffbbbbbbbffffffffffffffffffffffffffffffffffff00000000000000000000000ee000000000000000000000000000000000000000
ffffffffffffffffffffffffffffffffffffffffffffffffffffbbbbbbbfffff0000000000000000000000000000000000000000000000000000000000000000
ffffbbbbbbbbfffffffbbbfffffbbfffffffbbbbbbbffffffffbbbbbbbbbffff0000000000000000000000000000000000000000000000000000000000000000
ffbcccbbbbbbbbfffffbbbb888bbbbfffffbbbbbbbbbbfffffbbccc8cccbbfff0000000000000000000000000000000000000000000000000000000000000000
fbbccc8885cccbbfffbccb88888bccffffbbbbbbbbcccbbfffbcccc8ccccbbff0000000000000000000000000000000000000000000000000000000000000000
fbbb8888885cccbbffbcc8888888ccbffbbccc5888cccbbffbbcc58885ccbbbf0000000000000000000000000000000000000000000000000000000000000000
ffb880088885ccbbfbbcc8008008ccbfbbccc5888888bbbffbbc5888885cbbbf0000000000000000000000000000000000000000000000000000000000000000
ff8880788888ccbbfbbb887087088bbfbbcc588887088bfffbb588888885bbbf0000000000000000000000000000000000000000000000000000000000000000
ff888888888888bbfbbb888888888bbfbbcc8888800888fffbb888888888bbbf0000000000000000000000000000000000000000000000000000000000000000
ff8880088888ccbbfbbb888888888bbfbb888888888888fffbb888888888bbbf0000000000000000000000000000000000000000000000000000000000000000
ffb880788885ccbbfbbb588888885bbfbbcc8888870888fffbb880780788bbbf0000000000000000000000000000000000000000000000000000000000000000
fbbb8888885cccbbfbbbc5888885cbbfbbcc588880088bfffbcc8008008ccbbf0000000000000000000000000000000000000000000000000000000000000000
fbbccc8885cccbbffbbbcc58885ccbbfbbccc5888888bbbffbcc8888888ccbff0000000000000000000000000000000000000000000000000000000000000000
fbbcccbbbbbbbbffffbbcccc8ccccbfffbbccc5888cccbbfffccb88888bccbff0000000000000000000000000000000000000000000000000000000000000000
fffbbbbbbbbbbffffffbbccc8cccbbffffbbbbbbbbcccbffffbbbb888bbbbfff0000000000000000000000000000000000000000000000000000000000000000
fffffbbbbbbbffffffffbbbbbbbbbfffffffbbbbbbbbfffffffbbfffffbbbfff0000000000000000000000000000000000000000000000000000000000000000
fffffffffffffffffffffbbbbbbbffffffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000
__label__
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111111111111bbbbbbb111111111111111111111111111111111111111111111111111111111111111111111
1111111111111111111bbb11111bb1111111bbbbbbbb1111111bbbbbbbbb11111111bbbbbbbb1111111bbb11111bb11111111111111111111111111111111111
1111111111111111111bbbb333bbbb1111b333bbbbbbbb1111bb3333333bb11111b333bbbbbbbb11111bbbb333bbbb1111111111111111111111111111111111
111111111111111111b33b33333b33111bb3333335333bb111b333333333bb111bb3333335333bb111b33b33333b331111111111111111111111111111111111
111111111111111111b33333333333b11bbb3333335333bb1bb335333533bbb11bbb3333335333bb11b33333333333b111111111111111111111111111111111
11111111111111111bb33300300333b111b33003333533bb1bb353333353bbb111b33003333533bb1bb33300300333b111111111111111111111111111111111
11111111111111111bbb337037033bb111333073333333bb1bb533333335bbb111333073333333bb1bbb337037033bb111111111111111111111111111111111
11111111111111111bbb333333333bb111333333333333bb1bb333333333bbb111333333333333bb1bbb333333333bb111111111111111111111111111111111
11111111111111111bbb333333333bb111333003333333bb1bb333333333bbb111333003333333bb1bbb333333333bb111111111111111111111111111111111
11111111111111111bbb533333335bb111b33073333533bb1bb330730733bbb111b33073333533bb1bbb533333335bb111111111111111111111111111111111
11111111111111111bbb353333353bb11bbb3333335333bb1b33300300333bb11bbb3333335333bb1bbb353333353bb111111111111111111111111111111111
11111111111111111bbb335333533bb11bb3333335333bb11b33333333333b111bb3333335333bb11bbb335333533bb111111111111111111111111111111111
111111111111111111bb333333333b111bb333bbbbbbbb111133b33333b33b111bb333bbbbbbbb1111bb333333333b1111111111111111111111111111111111
1111111111111111111bb3333333bb11111bbbbbbbbbb11111bbbb333bbbb111111bbbbbbbbbb111111bb3333333bb1111111111111111111111111111111111
11111111111111111111bbbbbbbbb11111111bbbbbbb1111111bb11111bbb11111111bbbbbbb11111111bbbbbbbbb11111111111111111111111111111111111
111111111111111111111bbbbbbb111111111111111111111111111111111111111111111111111111111bbbbbbb111111111111111111111111111111111111
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111bbbbbbb111111111111111111111
11111111111111111111bbbbbbb111111111bbbbbbb1111111111111111111111111bbbbbbbb1111111bbb11111bb111111bbbbbbbbb11111111111111111111
1111111111111111111bbbbbbbbbb111111bbbbbbbbbb111111111111111111111b333bbbbbbbb11111bbbb333bbbb1111bb3333333bb1111111111111111111
111111111111111111bbbbbbbb333bb111bbbbbbbb333bb111111111111111111bb3333335333bb111b33b33333b331111b333333333bb111111111111111111
11111111111111111bb3335333333bb11bb3335333333bb111111111111111111bbb3333335333bb11b33333333333b11bb335333533bbb11111111111111111
1111111111111111bb3335333333bbb1bb3335333333bbb1111111111111111111b33003333533bb1bb33300300333b11bb353333353bbb11111111111111111
1111111111111111bb33533337033b11bb33533337033b11111111111111111111333073333333bb1bbb337037033bb11bb533333335bbb11111111111111111
1111111111111111bb33333330033311bb33333330033311111111111111111111333333333333bb1bbb333333333bb11bb333333333bbb11111111111111111
1111111111111111bb33333333333311bb33333333333311111111111111111111333003333333bb1bbb333333333bb11bb333333333bbb11111111111111111
1111111111111111bb33333337033311bb33333337033311111111111111111111b33073333533bb1bbb533333335bb11bb330730733bbb11111111111111111
1111111111111111bb33533330033b11bb33533330033b1111111111111111111bbb3333335333bb1bbb353333353bb11b33300300333bb11111111111111111
1111111111111111bb3335333333bbb1bb3335333333bbb111111111111111111bb3333335333bb11bbb335333533bb11b33333333333b111111111111111111
11111111111111111bb3335333333bb11bb3335333333bb111111111111111111bb333bbbbbbbb1111bb333333333b111133b33333b33b111111111111111111
111111111111111111bbbbbbbb333b1111bbbbbbbb333b111111111111111111111bbbbbbbbbb111111bb3333333bb1111bbbb333bbbb1111111111111111111
11111111111111111111bbbbbbbb11111111bbbbbbbb1111111111111111111111111bbbbbbb11111111bbbbbbbbb111111bb11111bbb1111111111111111111
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111bbbbbbb111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111bbbbbbb11111111111111111111111111111111111111111111111111111
11111111111111111111bbbbbbb111111111bbbbbbbb11111111bbbbbbb11111111bbbbbbbbb111111111111111111111111bbbbbbb111111111111111111111
1111111111111111111bbbbbbbbbb11111b333bbbbbbbb11111bbbbbbbbbb11111bb3333333bb1111111111111111111111bbbbbbbbbb1111111111111111111
111111111111111111bbbbbbbb333bb11bb3333335333bb111bbbbbbbb333bb111b333333333bb11111111111111111111bbbbbbbb333bb11111111111111111
11111111111111111bb3335333333bb11bbb3333335333bb1bb3335333333bb11bb335333533bbb111111111111111111bb3335333333bb11111111111111111
1111111111111111bb3335333333bbb111b33003333533bbbb3335333333bbb11bb353333353bbb11111111111111111bb3335333333bbb11111111111111111
1111111111111111bb33533337033b1111333073333333bbbb33533337033b111bb533333335bbb11111111111111111bb33533337033b111111111111111111
1111111111111111bb3333333003331111333333333333bbbb333333300333111bb333333333bbb11111111111111111bb333333300333111111111111111111
1111111111111111bb3333333333331111333003333333bbbb333333333333111bb333333333bbb11111111111111111bb333333333333111111111111111111
1111111111111111bb3333333703331111b33073333533bbbb333333370333111bb330730733bbb11111111111111111bb333333370333111111111111111111
1111111111111111bb33533330033b111bbb3333335333bbbb33533330033b111b33300300333bb11111111111111111bb33533330033b111111111111111111
1111111111111111bb3335333333bbb11bb3333335333bb1bb3335333333bbb11b33333333333b111111111111111111bb3335333333bbb11111111111111111
11111111111111111bb3335333333bb11bb333bbbbbbbb111bb3335333333bb11133b33333b33b1111111111111111111bb3335333333bb11111111111111111
111111111111111111bbbbbbbb333b11111bbbbbbbbbb11111bbbbbbbb333b1111bbbb333bbbb111111111111111111111bbbbbbbb333b111111111111111111
11111111111111111111bbbbbbbb111111111bbbbbbb11111111bbbbbbbb1111111bb11111bbb11111111111111111111111bbbbbbbb11111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111bbbbbbb1111111111111111111111111bbbbbbb111111111111111111111
1111bbbbbbb111111111bbbbbbbb1111111bbb11111bb1111111bbbbbbbb1111111bbbbbbbbb11111111bbbbbbb11111111bbbbbbbbb11111111111111111111
111bbbbbbbbbb11111b333bbbbbbbb11111bbbb333bbbb1111b333bbbbbbbb1111bb3333333bb111111bbbbbbbbbb11111bb3333333bb1111111111111111111
11bbbbbbbbcccbb11bb3333335333bb111b33b33333b33111bb3333335333bb111b333333333bb1111bbbbbbbb333bb111b333333333bb111111111111111111
1bbccc5888cccbb11bbb3333335333bb11b33333333333b11bbb3333335333bb1bb335333533bbb11bb3335333333bb11bb335333533bbb11111111111111111
bbccc5888888bbb111b33003333533bb1bb33300300333b111b33003333533bb1bb353333353bbb1bb3335333333bbb11bb353333353bbb11111111111111111
bbcc588887088b1111333073333333bb1bbb337037033bb111333073333333bb1bb533333335bbb1bb33533337033b111bb533333335bbb11111111111111111
bbcc88888008881111333333333333bb1bbb333333333bb111333333333333bb1bb333333333bbb1bb333333300333111bb333333333bbb11111111111111111
bb8888888888881111333003333333bb1bbb333333333bb111333003333333bb1bb333333333bbb1bb333333333333111bb333333333bbb11111111111111111
bbcc88888708881111b33073333533bb1bbb533333335bb111b33073333533bb1bb330730733bbb1bb333333370333111bb330730733bbb11111111111111111
bbcc588880088b111bbb3333335333bb1bbb353333353bb11bbb3333335333bb1b33300300333bb1bb33533330033b111b33300300333bb11111111111111111
bbccc5888888bbb11bb3333335333bb11bbb335333533bb11bb3333335333bb11b33333333333b11bb3335333333bbb11b33333333333b111111111111111111
1bbccc5888cccbb11bb333bbbbbbbb1111bb333333333b111bb333bbbbbbbb111133b33333b33b111bb3335333333bb11133b33333b33b111111111111111111
11bbbbbbbbcccb11111bbbbbbbbbb111111bb3333333bb11111bbbbbbbbbb11111bbbb333bbbb11111bbbbbbbb333b1111bbbb333bbbb1111111111111111111
1111bbbbbbbb111111111bbbbbbb11111111bbbbbbbbb11111111bbbbbbb1111111bb11111bbb1111111bbbbbbbb1111111bb11111bbb1111111111111111111
1111111111111111111111111111111111111bbbbbbb111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111111111111111111111111111111111111111111777777777777777771111111111111111111bbbbbbb111111111bbbbbbb111111111111111111111
11111111111111111111bbbbbbbb11111111bbbbbbb11111711bbb11111bb1117111bbbbbbbb1111111bbbbbbbbb1111111bbbbbbbbb11111111111111111111
111111111111111111b333bbbbbbbb11111bbbbbbbbbb111711bbbb333bbbb1171b333bbbbbbbb1111bb3333333bb11111bb3333333bb1111111111111111111
11111111111111111bb3333335333bb111bbbbbbbb333bb171b33b33333b33117bb3333335333bb111b333333333bb1111b333333333bb111111111111111111
11111111111111111bbb3333335333bb1bb3335333333bb171b33333333333b17bbb3333335333bb1bb335333533bbb11bb335333533bbb11111111111111111
111111111111111111b33003333533bbbb3335333333bbb17bb33300300333b171b33003333533bb1bb353333353bbb11bb353333353bbb11111111111111111
111111111111111111333073333333bbbb33533337033b117bbb337037033bb171333073333333bb1bb533333335bbb11bb533333335bbb11111111111111111
111111111111111111333333333333bbbb333333300333117bbb333333333bb171333333333333bb1bb333333333bbb11bb333333333bbb11111111111111111
111111111111111111333003333333bbbb333333333333117bbb333333333bb171333003333333bb1bb333333333bbb11bb333333333bbb11111111111111111
111111111111111111b33073333533bbbb333333370333117bbb533333335bb171b33073333533bb1bb330730733bbb11bb330730733bbb11111111111111111
11111111111111111bbb3333335333bbbb33533330033b117bbb353333353bb17bbb3333335333bb1b33300300333bb11b33300300333bb11111111111111111
11111111111111111bb3333335333bb1bb3335333333bbb17bbb335333533bb17bb3333335333bb11b33333333333b111b33333333333b111111111111111111
11111111111111111bb333bbbbbbbb111bb3335333333bb171bb333333333b117bb333bbbbbbbb111133b33333b33b111133b33333b33b111111111111111111
1111111111111111111bbbbbbbbbb11111bbbbbbbb333b11711bb3333333bb11711bbbbbbbbbb11111bbbb333bbbb11111bbbb333bbbb1111111111111111111
111111111111111111111bbbbbbb11111111bbbbbbbb11117111bbbbbbbbb11171111bbbbbbb1111111bb11111bbb111111bb11111bbb1111111111111111111
11111111111111111111111111111111111111111111111171111bbbbbbb11117111111111111111111111111111111111111111111111111111111111111111
111111111111111111111111111111111111111111111111777777777777777771111111111111111111bbbbbbb111111111bbbbbbb111111111111111111111
11111111111111111111bbbbbbb111111111bbbbbbb11111111bbbbbbbbb11111111bbbbbbb11111111bbbbbbbbb1111111bbbbbbbbb11111111111111111111
1111111111111111111bbbbbbbbbb111111bbbbbbbbbb11111bb3333333bb111111bbbbbbbbbb11111bb3333333bb11111bb3333333bb1111111111111111111
111111111111111111bbbbbbbb333bb111bbbbbbbb333bb111b333333333bb1111bbbbbbbb333bb111b333333333bb1111b333333333bb111111111111111111
11111111111111111bb3335333333bb11bb3335333333bb11bb335333533bbb11bb3335333333bb11bb335333533bbb11bb335333533bbb11111111111111111
1111111111111111bb3335333333bbb1bb3335333333bbb11bb353333353bbb1bb3335333333bbb11bb353333353bbb11bb353333353bbb11111111111111111
1111111111111111bb33533337033b11bb33533337033b111bb533333335bbb1bb33533337033b111bb533333335bbb11bb533333335bbb11111111111111111
1111111111111111bb33333330033311bb333333300333111bb333333333bbb1bb333333300333111bb333333333bbb11bb333333333bbb11111111111111111
1111111111111111bb33333333333311bb333333333333111bb333333333bbb1bb333333333333111bb333333333bbb11bb333333333bbb11111111111111111
1111111111111111bb33333337033311bb333333370333111bb330730733bbb1bb333333370333111bb330730733bbb11bb330730733bbb11111111111111111
1111111111111111bb33533330033b11bb33533330033b111b33300300333bb1bb33533330033b111b33300300333bb11b33300300333bb11111111111111111
1111111111111111bb3335333333bbb1bb3335333333bbb11b33333333333b11bb3335333333bbb11b33333333333b111b33333333333b111111111111111111
11111111111111111bb3335333333bb11bb3335333333bb11133b33333b33b111bb3335333333bb11133b33333b33b111133b33333b33b111111111111111111
111111111111111111bbbbbbbb333b1111bbbbbbbb333b1111bbbb333bbbb11111bbbbbbbb333b1111bbbb333bbbb11111bbbb333bbbb1111111111111111111
11111111111111111111bbbbbbbb11111111bbbbbbbb1111111bb11111bbb1111111bbbbbbbb1111111bb11111bbb111111bb11111bbb1111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111

__sfx__
000500002060024450210501e0401902016030130200f0200d0501160000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
0003000009450084500845007450074500745007450084500a4500d4501045013450184501f450194500000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010f000007135061350000009135071351f711000000510505135041350000007135051351c0151d0150313503135021350000005135031350a1050a135000000113502135031350413505135000000a13500000
010f00000c033225152e5153a515246152b7070a145350150c003290153200529005246152501526015220150c0331e0251f0252700524615225051a0152250522015225152201522515246150a7110a0001d005
0112000003744030250a7040a005137441302508744080251b7110a704037440302524615080240a7440a02508744087250a7040c0241674416025167251652527515140240c7440c025220152e015220150a525
011200000c033247151f5152271524615227151b5051b5151f5201f5201f5221f510225212252022522225150c0331b7151b5151b715246151b5151b5051b515275202752027522275151f5211f5201f5221f515
011200000c0330802508744080250872508044187151b7151b7000f0251174411025246150f0240c7440c0250c0330802508744080250872508044247152b715275020f0251174411025246150f0240c7440c025
011200002452024520245122451524615187151b7151f71527520275202751227515246151f7151b7151f715295202b5212b5122b5152461524715277152e715275002e715275022e715246152b7152771524715
011200002352023520235122351524615177151b7151f715275202752027512275152461523715277152e7152b5202c5212c5202c5202c5202c5222c5222c5222b5202b5202b5222b515225151f5151b51516515
011200000c0330802508744080250872508044177151b7151b7000f0251174411025246150f0240b7440b0250c0330802508744080250872524715277152e715080242e715080242e715246150f0240c7440c025
011600000042500415094250a4250042500415094250a42500425094253f2050a42508425094250a425074250c4250a42503425004150c4250a42503425004150c42500415186150042502425024250342504425
011600000c0330c4130f54510545186150c0330f545105450c0330f5450c41310545115450f545105450c0230c0330c4131554516545186150c03315545165450c0330c5450f4130f4130e5450e5450f54510545
0116000005425054150e4250f42505425054150e4250f425054250e4253f2050f4250d4250e4250f4250c4250a4250a42513425144150a4250a42513425144150a42509415086150741007410074120441101411
011600000c0330c4131454515545186150c03314545155450c033145450c413155451654514545155450c0230c0330c413195451a545186150c033195451a5451a520195201852017522175220c033186150c033
010b00200c03324510245102451024512245122751127510186151841516215184150c0031841516215134150c033114151321516415182151b4151d215224151861524415222151e4151d2151c4151b21518415
011400001051512515150151a5151051512515150151a5151051512515150151a5151051512515150151a5151051512515170151c5151051512515170151c5151051512515160151c5151051512515160151c515
011400000c0330253502525020450e6150252502045025250c0330253502525020450e6150252502045025250c0330252502045025350e6150204502535025250c0330253502525020450e615025250204502525
011400002c7252c0152c7152a0252a7152a0152a7152f0152c7252c0152c7152801525725250152a7252a0152072520715207151e7251e7151e7151e715217152072520715207151e7251e7151e7151e7151e715
011400000c0330653506525060450e6150652506045065250c0330653506525060450e6150652506045065250c0330952509045095350e6150904509535095250c0330953509525090450e615095250904509525
0114000020725200152071520015217252101521715210152c7252c0152c7152c0152a7252a0152a7152a015257252501525715250152672526015267153401532725310152d715280152672525015217151c015
010e000005145185111c725050250c12524515185150c04511045185151d515110250c0451d5151d0250c0450a0451a015190150a02505145190151a015050450c0451d0151c0150012502145187150414518715
010e000021745115152072521735186152072521735186052d7142b7142971426025240351151521035115151d0451c0051c0251d035186151c0251d035115151151530715247151871524716187160c70724717
010e000002145185111c72502125091452451518515090250e045185151d5150e025090451d5151d025090450a0451a015190150a02505045190151a015050450c0451d0151c0150012502145187150414518715
010e000029045000002802529035186152802529035000001a51515515115150e51518615000002603500000240450000023025240351861523025240350000015515185151c51521515186150c615280162d016
010e000002145185112072521025090452451518515090450e04521515265150e025090451d5151d01504045090451d01520015210250414520015210250404509045280152d0150702505145187150414518715
011a00000173401025117341102512734120250873408025127341202501734010251173411025087340802505734050250d7340d025147341402506734060250873408025127341202511734110250d7340d025
010d00200c0331b51119515195152071220712145151451518615317151d5151d515125050c03314515145150c0330150519515195150d517205161451514515186153171520515205150d5110c033145150c033
011a00000a7340a02511734110250d7340d02505734050250673406025147341402511734110250d7340d0250a7340a02511734110250d7340d02508734080250373403025127341202511734110250d7340d025
010d00200c0331b511295122951220712207122c5102c51018615315143151531514295150c03329515295150c0330150525515255150d517205162051520515186153171520515205150d5110c033145150c033
01180000021100211002110021120e1140e1100e1100e1120d1140d1100d1100d1120d1120940509110091120c1100c1100c1100c1120b1110b1100b1100b1120a1100a1100a1100a11209111091100911009112
01180000117201172011722117221d7201d7201d7221d7221c7211c7201c7201c7201c7221c72218720187221b7211b7201b7201b7201b7221b7221d7221d7221a7201a7201a7201a7201a7221a7221672016722
011800001972019720197221972218720187201872018720147201472015720157201f7211f7201d7201d7201c7201c7201c7221c7221a7201a7201a7221a7251a7201a7201a7221a72219721197201972219722
011800001a7201a7201a7221a7221c7201c7201c7221c7221e7201e7202172021720247212472023720237202272022720227202272022722227221f7201f7202272122720227202272221721217202172221722
0118000002114021100211002112091140911009110091120e1140e1100c1100c1120911209110081100811207110071100711007112061110611006110061120111101110011100111202111021100211002112
0118000020720207202072220722217202172021722217222b7212b72029720297202872128720267202672526720267202672026720267222672228721287202672026720267202672225721257202572225722
010e00000c0231951517516195150c0231751519516175150c0231951517516195150c0231751519516175150c023135151f0111f5110c0231751519516175150c0231e7111e7102a7100c023175151951617515
010e000000130070200c51000130070200a51000130070200c51000130070200a5200a5200a5120a5120a51200130070200c51000130070200a51000130070200c510001300b5200a5200a5200a5120a5120a512
010e00000c0231e5151c5161e5150c0231c5151e5161c5150c0231e5151c5161e5150c0231c5151e5161c5150c0230c51518011185110c0231c5151e5161c5150c0231e7111e7102a7100c023175151951617515
010e0000051300c02011010051300c0200f010051300c02011010051300c0200f0200f0200f0120f0120f012061300d02012010071300e02013010081300f0201503012020140101201015030120201401012010
010700000c5370f0370c5270f0270f537120370f527120271e537230371e527230272f537260372f52726027165371903716527190271c537190371c527210271c53621036245262102624536330362452633026
018800000074400730007320073200730007300073200732007300073200730007320073000732007320073200732007300073000730007320073000730007300073200732007300073000732007300073200732
01640020070140801107011060110701108011070110601100013080120701106511070110801707012060110c013080120701106011050110801008017005350053408010070110601100535080170701106011
018800000073000730007320073200730007300073200732007300073200730007320073000732007320073200732007300073000730007320073000730007300073200732007300073000732007300073200732
0164002006510075110851707512060110c0130801207011060110501108017070120801107011060110701108011075110651100523080120701108017005350053408012070110601100535080170701106511
011800001d5351f53516525275151d5351f53516525275151f5352053518525295151f5352053518525295151f5352053517525295151f5352053517525295151d5351f53516525275151d5351f5351652527515
010c00200c0330f13503130377140313533516337140c033306150c0330313003130031253e5153e5150c1430c043161340a1351b3130a1353a7143a7123a715306153e5150313003130031251b3130c0331b313
010c00200c0331413508130377140813533516337140c033306150c0330813008130081253e5153e5150c1330c0430f134031351b313031353a7143a7123a715306153e5150313003130031251b3130c0333e515
011800001f5452253527525295151f5452253527525295151f5452253527525295151f5452253527525295151f5452353527525295151f5452353527525295151f5452253527525295151f545225352752529515
010c002013035165351b0351d53513025165251b0251d52513015165151b0151d51513015165151b0151d51513015165151b0151d51513015165151b0151d51513015165151b0151d51513015165251b0351d545
011200000843508435122150043530615014351221502435034351221508435084353061512215054250341508435084350043501435306150243512215034351221512215084350843530615122151221524615
011200000c033242352323524235202351d2352a5111b1350c0331b1351d1351b135201351d135171350c0330c0332423523235202351d2351b235202352a5110c03326125271162c11523135201351d13512215
0112000001435014352a5110543530615064352a5110743508435115152a5110d43530615014352a511084150d4350d4352a5110543530615064352a5110743508435014352a5110143530615115152a52124615
011200000c033115152823529235282352923511515292350c0332823529216282252923511515115150c0330c033115151c1351d1351c1351d135115151d1350c03323135115152213523116221352013522135
0112000001435014352a5110543530615064352a5110743508435115152a5110d435306150143502435034350443513135141350743516135171350a435191351a1350d4351c1351d1351c1351d1352a5001e131
011200000c033115152823529235282352923511515292350c0332823529216282252923511515115150c0330c033192351a235246151c2351d2350c0331f235202350c033222352323522235232352a50030011
0114001800140005351c7341c725247342472505140055352173421725287342872504140045351f7341f725247342472502140025351d7341d72524734247250000000000000000000000000000000000000000
011400180c043287252b0152f72534015377253061528725290152d72530015377250c0432f7253001534725370153c725306152b7252d01532725370153b7250000000000000000000000000000000000000000
0114001809140095351f7341f7252473424725091400953518734187251f7341f72505140055351f7341f7252473424725051400553518734187251f7341f7250000000000000000000000000000000000000000
0114001802140025351f7341f725247342472504140045351f7341f725247342472505140055352b7242b715307243071507140075352b7242b71534724347150000000000000000000000000000000000000000
011400180c0433772534015307252f0152d725306152d7252f0153072534015377250c0433772534015307252f0152d725306152d7252f0153072534015377250000000000000000000000000000000000000000
011400180c0433c7253701534725300152f725306152f7253001534725370153c7250c0433c7253701534725300152f725306152f7253001534725370153c7250000000000000000000000000000000000000000
011400180c043287252b0152f725340153772530615287252901530725370153c7250c043287252901530725370153c72530615287252901530725370153c7250000000000000000000000000000000000000000
011400180c003287052b0052f705340053770530605287052900530705370053c7050c0032f7053000534705370053c705306052b7052d00532705370053b7050000000000000000000000000000000000000000
000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 00014344
00 00014344
01 00014344
00 00014344
00 02034344
02 02034344
00 04424344
00 04424344
00 04054344
00 04054344
01 04054344
00 04054344
00 06074344
02 08094344
01 0a0b4344
00 0c0d4344
00 0a0e4344
02 0c0e4344
00 10424344
01 100f4344
00 100f4344
00 10114344
00 12114344
02 12134344
01 14154344
00 14154344
00 16154344
00 16154344
00 18174344
02 16174344
00 19424344
01 191a4344
00 191a4344
00 1b1a4344
00 191c4344
02 1b1c4344
01 1d1e4344
00 1d1f4344
00 1d1e4344
00 1d1f4344
00 21204344
02 1d224344
00 27424344
01 24234344
00 24234344
02 26254344
01 28294344
03 2a2b4344
01 2d304344
00 2e304344
00 2d304344
00 2e304344
00 2d2c4344
00 2d2c4344
02 2e2f4344
01 31324344
00 31324344
00 33344344
02 35364344
01 3738433f
00 3738433f
00 393b433f
00 393c433f
02 3a3d433f


__meta:cart_info_start__
cart_type: game
game_name: Toxic Toads
# Leave blank to use game-name
game_slug: 
jam_info:
  - jam_name: TriJam
    jam_number: 118
    jam_url: null
    jam_theme: Toxicity
tagline: Infect all the toads!
time_left: '1:01:57'
develop_time: ''
description: |
  You are a toxic toad trying to make all the other toads toxic.
  Arrange the toads and then set off a chain reaction of toxicity!
controls:
  - inputs: [ARROW_KEYS]
    desc:  Navigate the grid of regular toads / move the toxic toad around the outside
  - inputs: [X,Z]
    desc:  When a regular toad is selected, rotates clockwise / counter-clockwise
  - inputs: [X]
    desc:  When the toxic toad is selected, infects the toad it is facing
hints: ''
acknowledgements: ''
to_do: []
version: 0.2.0
img_alt: Brightly colored toads on lily pads amongst green toads on lily pads
about_extra: |

  Also created for [Mini Jam 79](https://itch.io/jam/mini-jam-79-frogs)  
  Theme: Frogs

number_players: [1]
__meta:cart_info_end__
