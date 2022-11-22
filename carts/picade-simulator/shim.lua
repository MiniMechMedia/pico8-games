
-- Here
old_draw = _draw
old_init = _init

ssmemloc = 0x0000
original_saved_ss = 0x8000
picade_saved_ss = 0x8000 + 8192

function init_spritesheet()
	memcpy(original_saved_ss, ssmemloc, 8192)
end
minimapY = 21

function draw_header()
	palt(0, false)

	sspr(0,0,32,128,0,0)
	sspr(96,0,32,128,96,0)
	sspr(0,0,128,minimapY,0,0)
	sspr(32,minimapY+64,128,128,32,minimapY+64)
end


function draw_joystick()
  local buttons = {
    ['xunpressed'] = {
      x = 48,
      y = 32,
      sprite = 132
      -- width = 16,
      -- height = 16,
      -- cx = 8,
      -- cy = 21
    },
    ['xpressed'] = {
      x = 64,
      y = 32,
      sprite = 134
      -- width = 16,
      -- height = 16,
      -- cx = 8,
      -- cy = 21
    },
    ['pinkpressed'] = {
      -- x = 80,
      -- y = 95,
      sprite = 138
    },
    ['pinkunpressed'] = {
      -- sprite = 136
      sprite = 132
    }
  }
  local controls = {
    [''] = {
      sprite = 52,
      stick = 55,
      size = 3,
      size2=17,
      x = 30,
      y = 87,
      width = 17,
      height = 30,
      cx = 8,
      cy = 21
    },
    ['leftdown'] = {
      sprite = 52,
      stick = 59,
      size = 3,
      size2=18,
      x = 25,
      y = 89,
      width = 32,
      height = 26,
      cx = 119,
      cy = 52
    },
    ['leftup'] = {
      sprite = 52,
      stick = 70,
      size = 2,
      size2=16,
      x = 27,
      y = 87
    },
    ['left'] = {
      sprite = 52,
      stick = 57,
      size = 3,
      size2=17,
      -- This is pretty good for left-down tbh
      x = 25,
      y = 88,
      width = 32,
      height = 26,
      cx = 119,
      cy = 52
    },
    ['right'] = {
      sprite = 52,
      stick = 58,
      size = 3,
      size2=17,
      x = 34,
      y = 88,
      width = 32,
      height = 26,
      cx = 115,
      cy = 80
    },
    ['rightdown'] = {
      sprite = 52,
      stick = 74,
      size = 3,
      size2=18,
      x = 35,
      y = 89,
      width = 32,
      height = 26,
      cx = 119,
      cy = 52
    },
    ['rightup'] = {
      sprite = 52,
      stick = 71,
      size = 2,
      size2=16,
      x = 33,
      y = 87
    },
    ['up'] = {
      -- sprite = 52,
      -- stick = 70,
      -- size = 2,
      -- x = 25,
      -- y = 87
      sprite = 52,
      stick = 54,
      size = 2,
      size2=16,
      x = 30,
      y = 87,
      width = 17,
      height = 30,
      cx = 8,
      cy = 55
    },
    ['down'] = {
      sprite = 52,
      stick = 56,
      size = 3,
      size2=18,
      x = 29,
      y = 89,
      width = 18,
      height = 28,
      cx = 8,
      cy = 84
    }
  }

  -- local dir = 'neutral'
  local horiz = ''
  local vert = ''
  if btn(0) then
    horiz = 'left'
  elseif btn(1) then
    horiz = 'right'
  end
  if btn(2) then
    vert = 'up'
  elseif btn(3) then
    vert = 'down'
  end

  local dir = horiz .. vert
  -- if horiz == '' and vert == '' then
  --   dir = 'neutral'
  -- elseif horiz 
  -- end

  local ctrl = controls[dir]
  palt(11, true)
  palt(0, false)
  -- local xoff = ctrl.cx - ctrl.x
  -- local yoff = ctrl.cy - ctrl.y
  -- sspr(
  --   ctrl.x, 
  --   ctrl.y, 
  --   ctrl.width, 
  --   ctrl.height,
  --   38-xoff, 109-yoff)
  spr(ctrl.stick, 32+2, 96+5)
  --32,24
  sspr(32,40,17,17,ctrl.x,ctrl.y,
    ctrl.size2,ctrl.size2)
  -- spr(ctrl.sprite,
  --   ctrl.x,
  --   ctrl.y,
  --   2,2
  --   -- ctrl.size, ctrl.size
  --   )
  local sprite = 132
  if btn(5) then
    sprite = 134
  end
  spr(sprite, 58, 109, 2,2)
  local bx,by = 32, 64
  if btn(4) then
    bx = 48
  end
  sspr(bx, by, 
    16, 16,
    60+1, 97
    ,15,16
    )

  local sprite = 136
  if btn(0, 1) then
    sprite = 138
  end
  spr(sprite, 72, 105, 2,2)
  local bx,by = 64,64
  if btn(2, 1) then
    bx = 80
  end
  sspr(bx, by, 
    16, 16,
    74, 93
    ,15,16
    )

  local sprite = 88
  if btn(3, 1) then
    sprite = 90
  end
  spr(sprite, 86, 102, 2,2)
  local bx, by = 64, 40
  if btn(1, 1) then
    bx = 80
  end
  sspr(bx, by, 
    16, 16,
    88-1, 90
    ,15,15
    )

    --   73,
  --   104,
    --   ,
  --   ,

    --   74,
  --   93,

  -- local xbut = nil
  -- if btn(5) then
  --   xbut = buttons['xpressed']
  -- else
  --   xbut = buttons['xunpressed']
  -- end
  -- spr(
  --   xbut.sprite,
  --   58,
  --   109,2,2)
  -- -- sspr(
  -- --   xbut.x,
  -- --   xbut.y,
  -- --   xbut.width,
  -- --   xbut.height,
  -- --   58,
  -- --   109
  -- --   )

  -- local zbut = nil
  -- if btn(4) then 
  --   zbut = buttons['xpressed']
  -- else
  --   zbut = buttons['xunpressed']
  -- end
  -- spr(zbut.sprite,
  --   60,
  --   97,2,2)


  -- local pink1 = nil
  -- if btn(2, 1) then
  --   pink1 = buttons['pinkpressed']
  -- else
  --   pink1 = buttons['pinkunpressed']
  -- end
  -- -- pal({
  -- --   [10] = 14
  -- -- })
  -- spr(pink1.sprite,
  --   74,
  --   93,
  --   2,2)
  -- -- pal()
  -- local pink2 = btn(0,1) and buttons['pinkpressed'] or buttons['pinkunpressed']
  -- spr(136,--pink2.sprite,
  --   73,
  --   104,
  --   2,2)
  -- sspr(
  --   zbut.x,
  --   zbut.y,
  --   zbut.width,
  --   zbut.height,
  --   60,
  --   97
  --   )

  palt()
  pal()
end


firstDrawObject = {
	isFirstDraw = true
}
local default_drawstate = {
	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0,0,128,128,0,6,0,122,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0
}

function big_print(str, x, y, col)
  if (not str) str = ''
  if x and y then
    if col then
      old_print('\^t\^w' .. str, x, y, col)
    else
      old_print('\^t\^w' .. str, x, y)
    end
  else
    if col then
      old_print('\^t\^w' .. str, col)
    else
      old_print('\^t\^w' .. str)
    end
  end
end
is64x64 = false
function _draw()
	if firstDrawObject.isFirstDraw then
		init_spritesheet()
    if peek(0x5f2c) == 3 then
      is64x64 = true
      poke(0x5f2c,0)
    end
		firstDrawObject.isFirstDraw = false
	end

	local old_draw_state = {}
	for i = 0x5f00, 0x5f3f do
		add(old_draw_state, peek(i))
		-- poke(i, 0)
		-- TODO set draw state to sensible default
	end

	if old_draw then
    if not is64x64 then
      old_print = print
      print = big_print
    end

		-- Restore original sprite sheet
		memcpy(ssmemloc, original_saved_ss, 8192)
		old_draw()
    if not is64x64 then
      print = old_print
    end
	end
	-- if true then return end
	-- local cornerX, cornerY = 31, 32-8-1
	poke(0x5f54, 0x60)
	-- palt(0,false)

		-- poke(i, default_drawstate[i - 0x5f00 + 1])

	-- TODO
	-- camera()
	for i = 0x5f00, 0x5f3f do
		poke(i, default_drawstate[i - 0x5f00 + 1])
	end

  -- This makes the minimap
  if is64x64 then
    -- Just move it
    sspr(0,0,64,64, 32,minimapY,64,64) 
  else
  	sspr(0,0,128,128, 32,minimapY,64,64) 
  end
	-- palt()



	poke(0x5f54, 0x00)



	-- Restore the picade sprite sheet
	memcpy(ssmemloc, picade_saved_ss, 8192)

	-- palt(0,false)
	-- pal(11,13,0)
	draw_header()
	draw_joystick()
	pal()

	for i = 0x5f00, 0x5f3f do
		-- local nothing = nil
		poke(i, old_draw_state[i-0x5f00+1])
		-- add(old_draw_state, peek(i))
	end

  -- Restore the game's spritesheet
  -- so we don't corrupt the map for the
  -- update loop
  memcpy(ssmemloc, original_saved_ss, 8192)
end

-- End Here