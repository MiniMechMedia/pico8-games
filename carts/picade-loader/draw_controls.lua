
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