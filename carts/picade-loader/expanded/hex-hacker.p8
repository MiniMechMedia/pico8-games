pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
--hex hacker                     v0.2.0
--caterpillar games




dirs = {
	left = 0,
	right =1,
	up = 2,
	down = 3,
	z = 4,
	x = 5
}

firstDoor_a7 = 0xa7 
secondDoor_26 = 0x26
thirdDoor_9e = 0x9e

function makePlayer()
	return {
		x = 10,
		y = 10,
		dir = dirs.down,
		getLookingAt = function(self)
			if self.dir == dirs.left then
				return {
					x = self.x - 1,
					y = self.y
				}
			elseif self.dir == dirs.right then
				return {
					x = self.x + 1,
					y = self.y
				}
			elseif self.dir == dirs.up then
				return {
					x = self.x,
					y = self.y - 1
				}
			elseif self.dir == dirs.down then
				return {
					x = self.x,
					y = self.y + 1
				}
			else
				-- Shouldn't happen
				return {
					x = self.x,
					y = self.y
				}
			end

		end
	}
end

function makeEditor(
	memaddr, 
	initval,
	onchange,
	onsubmit,
	desc)
	return {
		memaddr = memaddr,
		curval = initval,
		onchange = onchange,
		onsubmit = onsubmit,
		desc = desc,
		length = length,
		curindex = 1,
		getIntValue = function(self) 
			local ret = 0
			for i = 1, #self.curval do
				ret = ret * 16 + self.curval[i]
			end
			return ret
		end,
		getCurHexitValue = function(self)
			return self.curval[self.curindex]
		end,
		canLower = function(self)
			return self:getCurHexitValue() > 0
		end,
		canRaise = function(self)
			return self:getCurHexitValue() < 15
		end,
		canLeft = function(self)
			return self.curindex > 1
		end,
		canRight = function(self)
			return self.curindex < #self.curval
		end,
		incrementVal = function(self)
			self.curval[self.curindex] += 1
			if self.onchange != nil then
				self:onchange()
			end
		end,
		decrementVal = function(self)
			self.curval[self.curindex] -= 1
			if self.onchange != nil then
				self:onchange()
			end
		end
	}
end

function getcharFromHexit(hexit)
	if hexit < 10 then
		return hexit
	end

	if hexit == 10 then
		return 'a'
	elseif hexit == 11 then
		return 'b'
	elseif hexit == 12 then
		return 'c'
	elseif hexit == 13 then
		return 'd'
	elseif hexit == 14 then
		return 'e'
	elseif hexit == 15 then
		return 'f'
	else
		return '?'
	end
end

-- Working memory...
reservedAddress = 0Xc0de

function _init()
	music(43)
	poke2(reservedAddress, 0)

	gs = {
		curAnimation = nil,
		hasAnimation = function(self)
			if self.curAnimation == nil or costatus(self.curAnimation) == 'dead' then
				return false
			else
				return true
			end
		end,
		loadTerminal = function(self)
			local lookingAt = self.player:getLookingAt()
			if lookingAt.x == 46 and lookingAt.y == 9 then
				self.activeEditor = self.mysticalTerminal
			else
				self.activeEditor = self.terminals[self.curRoom]
			end
		end,
		loadKeypad = function (self)
			self.activeEditor = self.keypads[self.curRoom]
		end,
		player = makePlayer(),
		curRoom = 1,
		activeEditor = nil,
		mysticalTerminal = makeEditor(
			reservedAddress,
			{0, 0, 0, 0},
			-- {13, 14, 10, 13},
			nil,
			function(self)
				-- local value = self:getIntValue()
				-- color(7)
				-- print(value)
				-- assert(false)
				-- poke4(self.memaddr, value)
				local firstByte = self.curval[1] * 16 + self.curval[2]
				local secondByte = self.curval[3] * 16 + self.curval[4]
				-- Endianness is weird...
				poke(self.memaddr, secondByte)
				poke(self.memaddr + 1, firstByte)
			end,
			'err'
			),
		terminals = {
			makeEditor(
								-- 0x5f02		-- changed rectangle color amazingly
				-- TODO change the clue...
				0x5f2a,
				-- {0, 13,15,22},
				{0},
				function(self)
					local value = self:getIntValue()
					poke(self.memaddr, value)
				end,
				nil,
				'addr: 0X5f2a\nspec: camera y'
				),
			makeEditor(
				0x5f31,
				-- {0, 0, 0, 0},
				{0},
				function(self)
					local value = self:getIntValue()
					value = 16 * 16 * 16 * value + 16 * 16 * value + 16 * value + value
					poke2(self.memaddr, value)
				end,
				nil,
				'addr: 0X5f31\nspec: bit mask\n  fill pattern'
				),
			makeEditor(
				-- x = 46
				-- y = 9
				-- 0x2000 + 9*128 + 46
				-- 0x24ae
				getMemLocFromMapLoc(46, 9)
				,
				{0},
				function(self)
					local value = self:getIntValue()
					poke(self.memaddr, value)
				end,
				nil,
				'addr: 0X24ae\nspec: map data'
				)
		},
		keypads = {
			makeEditor(
				getMemLocFromMapLoc(14, 10),
				{0, 0},
				nil,
				function(self)
					if self:getIntValue() == firstDoor_a7 then
					-- if true then
						poke(self.memaddr, 0)
						sfx(27)
					else
						-- Print bad code or something
						sfx(60)
					end
				end,
				'enter code'
				),
			makeEditor(
				getMemLocFromMapLoc(30, 10),
				{0, 0},
				nil,
				function(self)
					if self:getIntValue() == secondDoor_26 then
					-- if true then
						poke(self.memaddr, 0)
						sfx(27)
					else
						-- Print bad code or something
						sfx(60)
					end
				end,
				'enter code'
				),
			makeEditor(
				getMemLocFromMapLoc(46, 10),
				{0, 0},
				nil,
				function(self)
					if self:getIntValue() == thirdDoor_9e then
					-- if true then
						poke(self.memaddr, 0)
						sfx(27)
					else
						-- Print bad code or something
						sfx(60)
					end
				end,
				'enter code'
				)
		}
	}

	gs.player.x = 8
	-- gs.activeEditor = gs.terminals[1]
	-- poke(0x5f2a, 0xf)
	fillp(0b0000000000000000.1)

	-- poke(reservedAddress, 0xad)
	-- poke(reservedAddress+1, 0xde)
end

function acceptInput()
	-- TODO check if we have an editor
	if gs.activeEditor == nil then
		acceptMovement()
	else
		acceptEditorMovement()
	end
end

function acceptEditorMovement()
	local editor = gs.activeEditor
	if btnp(dirs.left) and editor:canLeft() then
		editor.curindex -= 1
	elseif btnp(dirs.right) and editor:canRight() then
		editor.curindex += 1
	elseif btnp(dirs.up) and editor:canRaise() then
		editor:incrementVal()
		-- editor.curval[editor.curindex] += 1
	elseif btnp(dirs.down) and editor:canLower() then
		editor:decrementVal()
		-- editor.curval[editor.curindex] -= 1

	elseif btnp(dirs.x) then
		if gs.activeEditor.onsubmit != nil then
			gs.activeEditor:onsubmit()
		end
		gs.activeEditor = nil
	end

end

function acceptMovement()
	local startX = gs.player.x
	local startY = gs.player.y
	if btnp(dirs.left) then
		gs.player.x -= 1
		gs.player.dir = dirs.left
	elseif btnp(dirs.right) then
		gs.player.x += 1
		gs.player.dir = dirs.right
	elseif btnp(dirs.down) then
		gs.player.y += 1
		gs.player.dir = dirs.down
	elseif btnp(dirs.up) then
		gs.player.y -= 1
		gs.player.dir = dirs.up
	end
	local sprite = mget(gs.player.x, gs.player.y)

	-- TODO!!!
	if sprite != 0 then
		gs.player.x = startX
		gs.player.y = startY
	end

	if btnp(dirs.x) then
		local looking = gs.player:getLookingAt()
		local sprite2 = mget(looking.x, looking.y)
		if fget(sprite2, 0) then
			gs:loadTerminal()
		elseif fget(sprite2, 1) then
			gs:loadKeypad()
		end
	end
end

function updateRoomIndex()
	local calculatedIndex = flr(gs.player.x / 16) + 1
	if calculatedIndex == gs.curRoom then
		-- print('returning early')
		return
	end

	local curCameraX = gs.curRoom * 128 - 128
	-- Make an animation
	gs.curRoom = calculatedIndex
	-- TODO poke it
	-- camera(calculatedIndex * 128 - 128, 0)
	-- local curCameraX = $0x5f2a
	local targetCameraX = calculatedIndex * 128 - 128
	gs.curAnimation = cocreate(function()
		for i = 0, 30 do
			local interpolated = curCameraX + (targetCameraX - curCameraX) * i / 30
			poke2(0x5f28, flr(interpolated))
			-- camera(interpolated, 0)
			yield()
		end
		poke2(0x5f28, targetCameraX)
		-- poke4(0x5f28, targetCameraX)
		-- camera(targetCameraX, 0)
	end)
end

function _update()
	if gs:hasAnimation() then
		coresume(gs.curAnimation)
		if gs.isFinalCrash then
			acceptInput()

			updateRoomIndex()
		end
	else
		acceptInput()

		updateRoomIndex()
	end
	-- poke2(0xc0de, 0xdead)
	crash_this_function_to_win()
end

function crash_this_function_to_win()
	if not gs.isFinalCrash then
	-- if true then
		sfx(60)
		gs.curAnimation = cocreate(function()
			gs.isFinalCrash = true
			for i = 0, 400 do
				for j = 1, i\5 do
					local loc = rnd(0x8000)
					if not (0x5f28 <= loc and loc <= 0x5f2b) then
						poke(loc,rnd(256))
					end
				end
				yield()
				if i >= 360 and i % 3 == 0 then
					sfx(60)
				end
			end
			gs.corruptionComplete = true
		end)
	end

	if gs.corruptionComplete then
		-- On the off chance we corrupted this value...
		-- set it
		poke2(0xc0de, 0xdead)

		assert(%0Xc0de != 0Xdead)
	end
end

function drawPlayer()
	spr(16 + gs.player.dir,
		gs.player.x * 8,
		gs.player.y * 8)
end

function drawClues()
	-- First room: Camera offset
	color(7)
	_ = firstDoor_a7
	print('a7', 60, 128 + 8)

	-- Second room: fillp 
	color(2)
	_ = secondDoor_26
	print('26', 128 + 60, 96)

	color(6)
	_ = thirdDoor_9e
	print('9e', 256 + 60, 96)

	-- For final room??
	color(0)
	-- Top half
	print('d_a_', 256 + 128 + 60, 8)
	-- Carpet
	print('_e_d', 256 + 128 + 60, 96)
end

function drawBackground()
	rectfill(0, 0, 128 * 4, 127, 2)

	map(0,0,0,0,64,16)
end

function getMemLocFromMapLoc(x, y)
	return 0x2000 + 128 * y + x
end

function drawActiveEditor()
	if gs.activeEditor == nil then
		return
	end

	local xOff = (gs.curRoom - 1) * 128
	local cornerY = 16
	local cornerX = 32 + xOff
	rectfill(cornerX, cornerY, cornerX + 64, cornerY + 64, 0)
	cornerX += 2
	cornerY += 2
	color(11)
	print(gs.activeEditor.desc, cornerX, cornerY)


	for i = 1, #gs.activeEditor.curval do
		local numberX = cornerX + 8 * i 
		local numberY = cornerY + 20 + 15
		local curHexitVal = gs.activeEditor.curval[i]
		local charRepr = getcharFromHexit(curHexitVal)
		print(charRepr, numberX, numberY)
		if i == gs.activeEditor.curindex then
			if curHexitVal < 15 then
				spr(22, numberX - 2, numberY - 10)
			end
			if curHexitVal > 0 then
				spr(23, numberX - 2, numberY + 7)
			end
		end
	end	

end

function _draw()
	cls(0)
	palt(0, false)
	palt(9, true)

	drawBackground()
	drawClues()
	
	-- Other stuff

	drawPlayer()

	drawActiveEditor()
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
000000009aaaaa9999aaaaa99aaaaa999aaaaa9966666666999999999bbbbb996666666665556555666666666555655555565556666666669944449961111111
000000009ffffaa99aaffff9aaaaaaa9afffffa9600000069999999999bbb9995565555565556555655565556555655555566666556555559444444961717181
007007009fcffaa99aaffcf9aaaaaaa9afcfcfa960b0000699999999999b99995565555565556666655565556555655555565556556555559444444961111181
000770009ffffaa99aaffff9aaaaaaa9afffffa9600b000699999999999999995565555565556555655565556555655566665556556555554444444461717111
0007700099eeeea99aeeee999eaaae999eeeee9960b00006999999999999999966666666655565556555666666666666555655566666666644444a4461111111
0070070099e7ee9aa9ee7e999eeaee999e7e7e9960000006999b9999999999995555565566666555655565556555556555565556555565554444444461717111
000000009eeeeee99eeeeee9eeeaeee9eeeeeee96000000699bbb999999999995555565565556555666665556555556555565556555565554444444461111111
000000009eeeeee99eeeeee9eeeeeee9eeeeeee9666666669bbbbb99999999995555565565556555655565556555556566666666555565554444444465556555
9aaaaa9999aaaaa99aaaaa999aaaaa996666666661111111999999999bbbbb990000000000000000999999999999999900000000000000000000000000000000
9ffffaa99aaffff9aaaaaaa9afffffa960000006617171819999999999bbb9990000000000000000999999999999999900000000000000000000000000000000
9fcffaa99aaffcf9aaaaaaa9afcfcfa960b000066111118199999999999b99990000000000000000999999999999999900000000000000000000000000000000
9ffffaa99aaffff9aaaaaaa9afffffa9600b00066171711199999999999999990000000000000000999999999999999900000000000000000000000000000000
99eeeea99aeeee999eaaae999eeeee9960b000066111111199999999999999990000000000000000999999999999999900000000000000000000000000000000
99e7ee9aa9ee7e999eeaee999e7e7e996000000661717111999b9999999999990000000000000000999999999999999900000000000000000000000000000000
9eeeeee99eeeeee9eeeaeee9eeeeeee9600000066111111199bbb999999999990000000000000000999999999999999900000000000000000000000000000000
9eeeeee99eeeeee9eeeeeee9eeeeeee966666666655565559bbbbb99999999990000000000000000999999999999999900000000000000000000000000000000
66666666655565559944449966666666655565555556555666666666000000000000000000000000666999999999999966666666000000000000000066666666
556555556555655594444449655565556555655555566666556555550000000000000000000000006776c1111111999955655555000008008000000055655555
556555556555666694444449655565556555655555565556556555550000000000000000000000006776ccccccc1199955655555000000008800000055655555
556555556555655544444444655565556555655566665556556555550000000000000000000000006776cccccccc199955655555000000808080000055655555
666666666555655544444a44655566666666666655565556666666660000000000000000000000004466cccccccc199966666666009008888888000066666666
5555565566666555444444446555655565555565555655565555655500000000000000000000000044ccccccccccc9995555565500008888aa88000055555655
5555565565556555444444446666655565555565555655565555655500000000000000000000000044ccccccccc449995555565500008a88aa88800055555655
55555655655565554444444465556555655555656666666655556555000000000000000000000000449999999994499955555655000a8a98a98a800055555655
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066666666000aaa99a9a9980066666666
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000556555550088aa99a9a9980055655555
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000556555550008a99aa9a9980055655555
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000556555550008aafaffff880055655555
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006666666600088fff777f800066666666
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005555565500008ff7777f800055555655
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055555655000000000000000055555655
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055555655000000000000000055555655
__label__
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
65556555556555555565555555655555556555555565555555655555556555555565555555655555556555555565555555655555556555555565555555655555
65556555556555555565555555655555556555555565555555655555556555555565555555655555556555555565555555655555556555555565555555655555
65556555556555555565555555655555556555555565555555655555556555555565555555655555556555555565555555655555556555555565555555655555
65556666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
65556555555556555555565555555655555556555555565555555655555556555555565555555655555556555555565555555655555556555555565555556555
66666555555556555555565555555655555556555555565555555655555556555555565555555655555556555555565555555655555556555555565555556555
65556555555556555555565555555655555556555555565555555655555556555555565555555655555556555555565555555655555556555555565555556555
65556555666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666665556555
65556555655565555565555555655555556555555565555555655555556555555565555555655555556555555565555555655555556555555565555565556555
65556666655565555565555555655555556555555565555555655555556555555565555555655555556555555565555555655555556555555565555565556666
65556555655565555565555555655555556555555565555555655555556555555565555555655555556555555565555555655555556555555565555565556555
65556555655566666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666665556555
66666555655565555555565555555655555556555555565555555655555556555555565555555655555556555555565555555655555556555555655566666555
65556555666665555555565555555655555556555555565555555655555556555555565555555655555556555555565555555655555556555555655565556555
65556555655565555555565555555655555556555555565555555655555556555555565555555655555556555555565555555655555556555555655565556555
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
65556666655566662222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555666665556666
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
66666555666665552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226666655566666555
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
65556666655566662222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555666665556666
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
66666555666665552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226666655566666555
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
65556666655566662222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555666665556666
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
66666555666665552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226666655566666555
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
65556666655566662222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555666665556666
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
66666555666665552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226666655566666555
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
65556666655566662222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555666665556666
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
66666555666665552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226666655566666555
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
65556666655566662222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555666665556666
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
66666555666665552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226666655566666555
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
65556555655565552222222222222222222222222222222222222222666666662222222222222222222222222222222222222222222222226555655565556555
65556555655565552222222222222222222222222222222222222222600000062222222222222222222222222222222222222222222222226555655565556555
6555666665556666222222222222222222222222222222222222222260b000062222222222222222222222222222222222222222222222226555666665556666
65556555655565552222222222222222222222222222222222222222600b00062222222222222222222222222222222222222222222222226555655565556555
6555655565556555222222222222222222222222222222222222222260b000062222222222222222222222222222222222222222222222226555655565556555
66666555666665552222222222222222222222222222222222222222600000062222222222222222222222222222222222222222222222226666655566666555
65556555655565552222222222222222222222222222222222222222600000062222222222222222222222222222222222222222222222226555655565556555
65556555655565552222222222222222222222222222222222222222666666662222222222222222222222222222222222222222222222226555655565556555
6555655565556555222222222222222222222222222222222222222222222222222222222222222222aaaaa22222222222222222222222226111111165556555
655565556555655522222222222222222222222222222222222222222222222222222222222222222aaffff22222222222222222222222226171718165556555
655566666555666622222222222222222222222222222222222222222222222222222222222222222aaffcf22222222222222222222222226111118165556666
655565556555655522222222222222222222222222222222222222222222222222222222222222222aaffff22222222222222222222222226171711165556555
655565556555655522222222222222222222222222222222222222222222222222222222222222222aeeee222222222222222222222222226111111165556555
66666555666665552222222222222222222222222222222222222222222222222222222222222222a2ee7e222222222222222222222222226171711166666555
655565556555655522222222222222222222222222222222222222222222222222222222222222222eeeeee22222222222222222222222226111111165556555
655565556555655522222222222222222222222222222222222222222222222222222222222222222eeeeee22222222222222222222222226555655565556555
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222244442222222222
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222444444222222222
65556666655566662222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222444444222222222
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222224444444422222222
655565556555655522222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222244444a4422222222
66666555666665552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222224444444422222222
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222224444444422222222
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222224444444422222222
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
65556666655566662222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555666665556666
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
66666555666665552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226666655566666555
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
65556666655566662222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555666665556666
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
66666555666665552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226666655566666555
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
65556666655566662222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555666665556666
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
66666555666665552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226666655566666555
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
65556555655565552222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226555655565556555
65556555655565556666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666665556555
65556555655565555565555555655555556555555565555555655555556555555565555555655555556555555565555555655555556555555565555565556555
65556666655565555565555555655555556555555565555555655555556555555565555555655555556555555565555555655555556555555565555565556666
65556555655565555565555555655555556555555565555555655555556555555565555555655555556555555565555555655555556555555565555565556555
65556555666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666665556555
66666555655555655555565555555655555556555555565555555655555556555555565555555655555556555555565555555655555556555555655566666555
65556555655555655555565555555655555556555555565555555655555556555555565555555655555556555555565555555655555556555555655565556555
65556555655555655555565555555655555556555555565555555655555556555555565555555655555556555555565555555655555556555555655565556555
65556555666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
65556555556555555565555555655555556555555565555555655555556555555565555555655555556555555565555555655555556555555565555555655555
65556555556555555565555555655555556555555565555555655555556555555565555555655555556555555565555555655555556555555565555555655555
65556555556555555565555555655555556555555565555555655555556555555565555555655555556555555565555555655555556555555565555555655555
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
65555565555556555555565555555655555556555555565555555655555556555555565555555655555556555555565555555655555556555555565555556555
65555565555556555555565555555655555556555555565555555655555556555555565555555655555556555555565555555655555556555555565555556555
65555565555556555555565555555655555556555555565555555655555556555555565555555655555556555555565555555655555556555555565555556555

__gff__
0000000000010000000000000000000200000000010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
2320202020202020202020202020202623202020202020202020202020202026232020202020202020202020202020262320202020202020202020202020202600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2123202020202020202020202020262121232020202020202020202020202621212320202020202020202020202026212123202020202020202020202020262100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121000000000000000000000000212121210000000000000000000000002121212100000000000000000000000021212121000000000000000000000000212100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121000000000000000000000000212121210000000000000000000000002121212100000000000000000000000021212121000000000000000000000000212100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121000000000000000000000000212121210000000000000000000000002121212100000000000000000000000021212121000000000000000000000000212100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121000000000000000000000000212121210000000000000000000000002121212100000000000000000000000021212121000000000000000000000000212100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121000000000000000000000000212121210000000000000000000000002121212100000000000000000000000021212121000000000000000000000000212100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121000000000000000000000000212121210000000000000000000000002121212100000000000000000000000021212121000000000000000000000000212100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121000000000014000000000000212121210000000000140000000000002121212100000000001400000000000021212121000000000000000000000000212100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121000000000000000000000000152121210000000000000000000000001521212100000000000000000000000021212121000000000000000000000000212100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121000000000000000000000000220000000000000000000000000000002200000000000000000000000000000022000000000000000000000000000000212100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121000000000000000000000000212121210000000000000000000000002121212100000000000000000000000021212121000000000000000000000000212100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121000000000000000000000000212121210000000000000000000000002121212100000000000000000000000021212121000000000000000000000000212100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121000000000000000000000000212121210000000000000000000000002121212100000000000000000000000021212121000000000000000000000000212100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2124202020202020202020202020262121242020202020202020202020202621212420202020202020202020202026212124202020202020202020202020262100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2420202020202020202020202020202624202020202020202020202020202026242020202020202020202020202020262420202020202020202020202020202600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00020000107531375515755187551d7552375526755277552775324755217551d75517755127551175510755107531075500705107053f7050070510705007050c7031070510705007053f705007051070500705
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
00010000096550c6550c6550b655076550365503655046550465505655056552670221e0526e0528e052670228f052af052df053270232e0534e0537e052de052de052de052af0528f0528f0526e052d7022df05
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
game_name: Hex Hacker
# Leave blank to use game-name
game_slug: 
jam_info:
  - jam_name: TriJam
    jam_number: 97
    jam_url: null
    jam_theme: Unorthodox Solutions / Illegal Actions
tagline: "Q: How do you defeat an evil hex? A: Use a hex editor"
develop_time: 2h 59m 58s
description: |
  An evil wizard put a hex on you, trapping you in a tower. 
  Use a hex [editor] of your own to hack your way through the challenges. 
  It will take drastic measures to break out once and for all.

  **Sound Warning** - There may be loud noises
controls:
  - inputs: [ARROW_KEYS]
    desc:  move player, navigate menu
  - inputs: [X]
    desc:  interact with object, close menu
hints: ''
acknowledgements: |
  Music is from [Gruber](https://www.lexaloffle.com/bbs/?uid=11292)'s [Pico-8 Tunes Vol. 2](https://www.lexaloffle.com/bbs/?tid=33675), Track 6 - Eyes in the Dark 
  Licensed under [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/)

  This game is based on features of the PICO-8 virtual machine.
  Check out the [wiki](https://pico-8.fandom.com/wiki/Memory) to find out more
to_do: []
version: 0.2.0
img_alt: Princess in locked room with computer terminal

number_players: [1]
__meta:cart_info_end__
