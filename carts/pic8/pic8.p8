pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
--picade simulator               v0.1.0
--caterpillar games

-- ⬅️⬆️⬇️➡️
-- ❎🅾️

-- Look it up...
function
	px9_decomp(x0,y0,src,vget,vset)

	local function vlist_val(l, val)
		-- find position and move
		-- to head of the list

--[ 2-3x faster than block below
		local v,i=l[1],1
		while v!=val do
			i+=1
			v,l[i]=l[i],v
		end
		l[1]=val
--]]

--[[ 7 tokens smaller than above
		for i,v in ipairs(l) do
			if v==val then
				add(l,deli(l,i),1)
				return
			end
		end
--]]
	end

	-- read an m-bit num from src
	local function getval(m)
		-- $src: 4 bytes at flr(src)
		-- >>src%1*8: sub-byte pos
		-- <<32-m: zero high bits
		-- >>>16-m: shift to int
		local res=$src >> src%1*8 << 32-m >>> 16-m
		src+=m>>3 --m/8
		return res
	end

	-- get number plus n
	local function gnp(n)
		local bits=0
		repeat
			bits+=1
			local vv=getval(bits)
			n+=vv
		until vv<(1<<bits)-1
		return n
	end

	-- header

	local
		w_1,h_1,      -- w-1,h-1
		eb,el,pr,
		splen,
		predict
		=
		gnp"0",gnp"0",
		gnp"1",{},{},
		0
		--,nil

	for i=1,gnp"1" do
		add(el,getval(eb))
	end
	for y=y0,y0+h_1 do
		for x=x0,x0+w_1 do
			splen-=1

			if splen<1 then
				splen,predict=gnp"1",not predict
			end

			local a=y>y0 and vget(x,y-1) or 0

			-- create vlist if needed
			local l=pr[a] or {unpack(el)}
			pr[a]=l

			-- grab index from stream
			-- iff predicted, always 1

			local v=l[predict and 1 or gnp"2"]

			-- update predictions
			vlist_val(l, v)
			vlist_val(el, v)

			-- set
			vset(x,y,v)
		end
	end
end

function spacetext(text, line_length, indent)
  line_length = line_length or 12
  indent = indent or false
  
  local lines = {}
  local words = split(text, " ", false)
  -- printh("text: " .. text)
  -- printh("words count: " .. #words)
  -- for i=1,#words do
  --   printh("word " .. i .. ": " .. words[i])
  -- end
  
  function ljust(str, width)
    while #str < width do
      str = str.." "
    end
    return str
  end
  
  function join(arr, sep)
    local result = ""
    for i=1,#arr do
      result = result..(i > 1 and sep or "")..arr[i]
    end
    return result
  end

  function char_width(c)
    if c == "⬅️" or c == "⬆️" or c == "⬇️" or c == "➡️" or c == "❎" or c == "🅾️" then
      return 2
    end
    return 1
  end

  function width(str)
    local w = 0
    for i=1,#str do
      w += char_width(str[i])
    end
    return w
  end

  function push_line(str)
    add(lines, ljust(str, line_length))
  end

  function split_long_word(word)
    local result = {}
    local part = ""
    local part_width = 0
    for i=1,#word do
      local c = word[i]
      local cw = char_width(c)
      if part_width + cw > line_length and #part > 0 then
        add(result, part)
        part = ""
        part_width = 0
      end
      part = part .. c
      part_width += cw
    end
    if #part > 0 then
      add(result, part)
    end
    return result
  end

  local current_line = ""
  for i=1,#words do
    local word = words[i]
    local handled = false
    if width(word) > line_length then
      if current_line != "" then
        push_line(current_line)
        current_line = ""
      end
      local segments = split_long_word(word)
      for j=1,#segments do
        local seg = segments[j]
        local is_last = j == #segments
        if not is_last then
          push_line(seg)
        else
          if width(seg) == line_length then
            push_line(seg)
            current_line = ""
          else
            current_line = seg
          end
        end
      end
      handled = true
    end
    if not handled then
      local space_needed = current_line != "" and 1 or 0
      local indent_penalty = (indent and #lines > 0) and 1 or 0
      local will_fit = width(current_line) + width(word) + space_needed + indent_penalty <= line_length
      
      if will_fit then
        if current_line != "" then
          current_line = current_line.." "
        end
        current_line = current_line..word
      else
        push_line(current_line)
        current_line = word
      end
    end
  end
  
  if current_line != "" then
    push_line(current_line)
  end
  
  if indent then
    return join(lines, "\n ")
  else
    return join(lines, "\n")
  end
end

function normalize_sort_key(str)
  local result = ""
  for i=1,#str do
    local c = str[i]
    if c >= 'a' and c <= 'z' then
      result = result .. chr(ord(c)-32)
    else
      result = result .. c
    end
  end
  return result
end

function sort_games_by_name(games)
  local sorted = {}
  for game in all(games) do
    -- if game.name then
      add(sorted, game)
    -- end
  end
  for i=2,#sorted do
    local key = sorted[i]
    local key_sort = key.sort_key
    local j = i-1
    while j >= 1 and sorted[j].sort_key > key_sort do
      sorted[j+1] = sorted[j]
      j -= 1
    end
    sorted[j+1] = key
  end
  return sorted
end


function makeGame(path, name, label_image_cart, controls, description, compressed_label_string, is_tweet)
  local controls_list = split(controls, "\n", false)
  for i=1,#controls_list do
    controls_list[i] = spacetext(controls_list[i], 16, true)
  end
  local raw_name = name
  local sort_key = normalize_sort_key(raw_name)
  local wrapped_name = spacetext(raw_name, 12)
  local wrapped_description = spacetext(description, 16)
  local wrapped_controls = join(controls_list, "\n")
  local detail = wrapped_description
  if #wrapped_controls > 0 then
    detail = detail .. "\n\n" .. wrapped_controls
  end
  return {
    path = path,
    name = wrapped_name,
    raw_name = raw_name,
    sort_key = sort_key,
    label_image_cart = label_image_cart,
    description = wrapped_description,
    controls = wrapped_controls,
    detail_text = detail,
    label = '',
    compressed_label_string = compressed_label_string,
    is_tweet = is_tweet,
  }
end

DETAIL_FRAME_X1 = 57
DETAIL_FRAME_Y1 = -1
DETAIL_FRAME_X2 = 126
DETAIL_FRAME_Y2 = 127
DETAIL_CLIP_X = DETAIL_FRAME_X1 + 1
DETAIL_CLIP_Y = 65
DETAIL_CLIP_RIGHT = DETAIL_FRAME_X2 - 1
DETAIL_CLIP_BOTTOM = DETAIL_FRAME_Y2 - 1
DETAIL_CLIP_W = DETAIL_CLIP_RIGHT - DETAIL_CLIP_X + 1
DETAIL_CLIP_H = DETAIL_CLIP_BOTTOM - DETAIL_CLIP_Y + 1
DETAIL_TEXT_X = DETAIL_CLIP_X + 1
DETAIL_TEXT_Y = DETAIL_CLIP_Y + 1
DETAIL_IMAGE_X = 60
DETAIL_IMAGE_Y = 2
DETAIL_BORDER_LIGHT = 6
DETAIL_BORDER_DARK = 0
DETAIL_SCROLL_WAIT = 90
DETAIL_SCROLL_SPEED = 0.25
LOGO_X = 2
LOGO_BASE_Y = -11

function _init()
  -- GAMES = {{}}
  sorted_games = sort_games_by_name(GAMES)
  GAMES = {}
  for g in all(sorted_games) do
    if not g.is_tweet then
      add(GAMES, g)
    end
  end

  -- camera(0, -1)
  poke(24365,1)
  -- All sub-games will refer to this region
  -- memcpy(0x8000 + 8192, 0x0000, 8192)
  -- function makeGame(path, name, desc, sprite)
  --   return {
  --     slug = slug,
  --     desc = desc,
  --     sprite = sprite
  --   }
  -- end
  local initIndex = peek(0x4300)
  if (initIndex == 0) initIndex = 1
  if (initIndex > #GAMES) initIndex = #GAMES
  gs = {
    index = initIndex,
    scroll_y = 0,
    last_nav = 'down',
    games = GAMES,
    detail_scroll = {offset=0, dir=1, wait=DETAIL_SCROLL_WAIT},
    -- games = {
    --   -- makeGame('beat-bot', 'beat bot    ', 122),
    --   makeGame('_game0', 'campfire    \n simulator  ', 122),
    --   makeGame('_game1',  'cannonbubs  ', 72),
    --   makeGame('_game2', 'countdown to\n meltdown   ', 118),
    --   makeGame('_game3', 'fetch quest ', 68),
    --   makeGame('_game4', 'grow big or \n go home    ', 119),
    --   makeGame('_game5', 'hamster slam', 87),
    --   -- makeGame('hex-hacker', 'hex hacker  ', 0),
    --   makeGame('_game6', 'lofty lunch ', 69),
    --   -- makeGame('make-cow',   'make cow    ', 90),
    --   makeGame('_game7', 'paybac man  ', 53),
    --   -- makeGame('picade-mini2','picade      ', 103),
    --   -- makeGame('health-inspectre', 'hi', 0),
    --   makeGame('_game8', 'pursuit in  \n progress   ', 75),
    --   makeGame('_game10',  'slylighter  ', 121),
    --   makeGame('_game9','skater tater', 123),
    --   makeGame('_game11',  'tile isle   ', 52),
    --   makeGame('_game12','toxic toads ', 73)
    --   -- makeGame('cool-cat-cafe', 'cool cat    \n cafe       ', 0),
    -- }
    images = {},
  }
  snap_scroll_to_selected()
  if #gs.games > 0 then
    load_label_image(gs.games[gs.index])
    reset_detail_scroll()
  end
  -- todo finalize music
 music(24)
  
-- 2MB 0x1000 pixels per label image = 0x0800 bytes per image
-- in array form, this is 4 * 0x0800 = 0x2000 bytes per image
-- 2mb / 0x2000 = 256 images
-- = 42 - 64 cartridges
-- 64k char limit / 0x0800 characters = 32 images
-- with compression, could zush that up to 128 - 160  images...

--  for game in all(gs.games) do
--   gs.images[game.name] = {}
--   -- reload_result = reload(0x0000, 0x0000, 0x2000/2, game.label_image_cart)
--   -- printh(ls())
--   -- for f in all(ls()) do
--   --   printh(game.name)
--   -- end
--   -- printh(reload_result)
--   -- for i = 1, 0x2000/2 do
--   --   gs.images[game.name][i] = peek(0x0000 + i-1)
--   -- end
--  end
--  for image_index = 0, 18 do
--   gs.images[image_index] = {}
--   -- reload(0x0000, 0x0000, 0x2000, "images" .. image_index .. ".p8")
--   -- for i = 1, 0x2000 do
--   --   gs.images[image_index][i] = peek(0x0000 + i-1)
--   -- end
--  end

end
function load_label_image(game)
  -- if true then return end
  poke(0x2000, ord(game.compressed_label_string, 1, #game.compressed_label_string))
  for k = 0, 1000 do
    poke(0x2000 + #game.compressed_label_string + k, 0)
  end
  -- printh('startlabel')
  -- for i = 0x2000, 0x2000 + #game.compressed_label_string do
  --   printh(peek(i))
  -- end
  -- printh('endlabel')
  px9_decomp(0,0,0x2000,sget,sset)
  -- index = 2
  -- printh('here is the index' .. index)
  -- printh('length ' .. #gs.images[index])
  -- res = poke(0x0000, unpack(gs.images[index]))
  -- printh('here')
  -- assert(false)
  -- res = poke(0x0000, unpack(gs.images[game_name]))
  -- printh('result of poking stuff' .. #gs.images[game_name])
end
function _update60()
 local start_index = gs.index
 if btnp(2) then
  -- assert(false)
  gs.index -= 1
  gs.last_nav = 'up'
  if gs.index <= 0 then
    gs.index = #gs.games
    gs.last_nav = 'down'
  end
 elseif btnp(3) then
  gs.index += 1
  gs.last_nav = 'down'
  if gs.index > #gs.games then
    gs.index = 1
    gs.last_nav = 'up'
  end
 elseif (btnp(❎)) then
  poke(0x4300, gs.index)
  load(
    gs.games[gs.index].path, "main menu")
  -- printh("Loading game: paybac-man")
  -- res = load('/carts/paybac-man/paybac-man.p8', 'main menu')
  -- printh(res)
  -- printh('wt')
  end
  -- assert(false)
  if start_index != gs.index then
    -- assert(false)
    -- printh(gs.games[gs.index].name)
    -- printh('desc:' .. gs.games[gs.index].description)
    -- poke(0, unpack(gs.games[gs.index].label))
    local cart_image_index = (start_index - 1) \ 4
    -- reload(0x0000, 0x0000, 0x2000, "images" .. cart_image_index .. ".p8")
    -- myreload(cart_image_index, gs.games[gs.index].name)
    load_label_image(gs.games[gs.index])
    reset_detail_scroll()
    -- printh(gs.games[gs.index].name .. 'wut')
  end
  update_detail_scroll(gs.games[gs.index])
end


function update_detail_scroll(game)
  local ds = gs.detail_scroll
  if not ds or not game then return end
  local text = game.detail_text or ''
  local total_height = measure_text_height(text) * 6
  local visible_height = DETAIL_CLIP_H
  if total_height <= visible_height then
    ds.offset = 0
    ds.dir = 1
    ds.wait = DETAIL_SCROLL_WAIT
    return
  end
  if ds.wait > 0 then
    ds.wait -= 1
    return
  end
  ds.offset += ds.dir * DETAIL_SCROLL_SPEED
  local max_offset = total_height - visible_height
  if ds.offset < 0 then
    ds.offset = 0
    ds.dir = 1
    ds.wait = DETAIL_SCROLL_WAIT
  elseif ds.offset > max_offset then
    ds.offset = max_offset
    ds.dir = -1
    ds.wait = DETAIL_SCROLL_WAIT
  end
end


function draw_joystick()
  local buttons = {
    ['xunpressed'] = {
      x = 48,
      y = 32,
      sprite = 132
    },
    ['xpressed'] = {
      x = 64,
      y = 32,
      sprite = 134
    },
    ['pinkpressed'] = {
      sprite = 138
    },
    ['pinkunpressed'] = {
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

  local ctrl = controls[dir]
  palt(11, true)
  palt(0, false)
  spr(ctrl.stick, 32+2, 96+5)
  sspr(32,40,17,17,ctrl.x,ctrl.y,
    ctrl.size2,ctrl.size2)
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
		poke(24365,1)
  local sprite = 136
  if btn(0, 1) or stat(28,225) then
    sprite = 138
  end
  spr(sprite, 72, 105, 2,2)
  local bx,by = 64,64
  if btn(2, 1) or stat(28,44) then
    bx = 80
  end
  sspr(bx, by, 
    16, 16,
    74, 93
    ,15,16
    )

  local sprite = 88
  if btn(3, 1) or stat(28,226) then
    sprite = 90
  end
  spr(sprite, 86, 102, 2,2)
  local bx, by = 64, 40
  if btn(1, 1) or stat(28,224) then
    bx = 80
  end
  sspr(bx, by, 
    16, 16,
    88-1, 90
    ,15,15
    )

  palt()
  pal()
end

-------------------------------
function _draw()
 palt(0,false)
 palt(11, false)
 cls(13)
 sspr(0,0,128,128,0,0)
 sspr(17,0,128,21,17, 0)

 -- Left Bar
 sspr(18, 0, 14, 96, 18, 0)

 -- right bar
 sspr(96, 0, 9, 96, 96, 0)

 -- bottom console part 1
 sspr(17, 85, 95, 30, 17, 85)

 -- bottom console part 2
 sspr(0, 96, 128, 32, 0, 96)

 draw_joystick()

 palt()
 
  palt(14, true)

  palt()
  draw_ui()
  -- sspr(0,0,128,128,0,0)


end -- draw

function measure_text_height(str)
  local ret = 1
  for i = 1, #str do
    if str[i] == '\n' then
      ret += 1
    end
  end
  return ret
end

function calculate_game_positions()
  if not gs or not gs.games then return end
  local curY = 23
  for i = 1, #gs.games do
    local game = gs.games[i]
    local botY = curY + measure_text_height(game.name) * 6
    game.topY = curY
    game.botY = botY
    curY = botY + 3
  end
end

function snap_scroll_to_selected()
  if not gs or not gs.games or #gs.games == 0 then return end
  calculate_game_positions()
  local game = gs.games[gs.index]
  if not game then return end

  local min_scroll = 24 - game.topY
  local max_scroll = 77 - game.botY
  if min_scroll > max_scroll then
    gs.scroll_y = min_scroll
    return
  end

  local guard = 0
  while guard < 128 do
    local curY = 24 - gs.scroll_y
    local screenBot = curY + 58
    if game.botY > screenBot - 5 then
      gs.scroll_y -= 10
    elseif game.topY < curY then
      gs.scroll_y += 10
    else
      break
    end
    guard += 1
  end
end

function reset_detail_scroll()
  local ds = gs and gs.detail_scroll
  if not ds then return end
  ds.offset = 0
  ds.dir = 1
  ds.wait = DETAIL_SCROLL_WAIT
end

function clip_to_screen()
    -- clip(32, 21, 64,64)
end

function draw_ui()

  -- TODO space out the diagonals a little more
  -- rectfill(
  --   32,
  --   21,
  --   32+64-1,
  --   21+64-1,
  --   0
  -- )
  cls(0)
  clip_to_screen()
  for i = -150, 150, 5 do
    line(0, 0+i, 128, 128+i, 5)
  end
  clip()
  clip_to_screen()
  draw_logo()
  -- todo this can be pre-computed
  -- local screenTop = 24 + gs.scroll_y
  -- local screenBot = screenTop + 64
  calculate_game_positions()

  -- Why is this backwards?
  local curY = 24 - gs.scroll_y
  local screenBot = curY + 64 - 6
  for i = 1, #gs.games do
    local game = gs.games[i]
    if i==gs.index and game.botY > screenBot-5 then
      gs.scroll_y -= 10
      break
    elseif i == gs.index and game.topY < curY then
      gs.scroll_y += 10
      break
    end
  end

  local y = 10 +1* gs.scroll_y -- + 10 * (i-1)
  for i = 1, #gs.games do
  -- for game in all(games) do
    local game = gs.games[i]
    local name = game.name
    local xstart = 2
    if i == gs.index then
      name = '\#6' .. name--spaceText(name, 12)
      print(name, xstart, y, 8)
      palt(0, false)
      -- rectfill(83, 25, 92, 36, 6)
      -- pset(92, 36, 0)
      -- pset(91, 36, 0)
      -- pset(92, 35, 0)
      -- spr(game.sprite, 84, 26)
      -- if game.slug == 'countdown-to-meltdown' then
      --   pset(84, 26, 0)
      -- end


    else
      -- print(spaceText(name, 12), xstart, y, 7)
      print(name, xstart, y, 7)
    end
    y += 3 + (measure_text_height(name)) * 6
  end
  local game = gs.games[gs.index]
  rectfill(DETAIL_FRAME_X1, DETAIL_FRAME_Y1, DETAIL_FRAME_X2, DETAIL_FRAME_Y2, 13)
  rectfill(DETAIL_CLIP_X, DETAIL_CLIP_Y, DETAIL_CLIP_RIGHT, DETAIL_CLIP_BOTTOM, 0)
  clip(DETAIL_CLIP_X, DETAIL_CLIP_Y, DETAIL_CLIP_W, DETAIL_CLIP_H)
  -- print(game.description, 61, 70, 7)
  -- print(game.description, 59, 68, 7)
  -- x,y,c=cursor()
  -- cursor(x,y+1,c)
  -- print(game.controls)
  local offset = flr(gs.detail_scroll.offset or 0)
  print(game.detail_text, DETAIL_TEXT_X, DETAIL_TEXT_Y - offset, 7)
  -- print(game.controls)
  -- print(game.controls, 59, 68, 7)
  clip()
  -- printh('here i am')
  -- myreload(gs.index \ 4, game.name)
  -- index = (gs.index - 1) % 4
  index = 0
  sprite_index = ({0, 8, 128, 136})[index + 1]
  palt(0, false)
  spr(sprite_index, 60, 0, 8, 8)
  -- spr(0, DETAIL_IMAGE_X, DETAIL_IMAGE_Y, 8, 8)
  draw_detail_border()


end

function draw_logo()
  if not gs then return end
  local y = LOGO_BASE_Y + gs.scroll_y
  -- print('PIC8', LOGO_X, y, 7)
  spr(8, LOGO_X, y, 6,2)
end

function draw_detail_border()
if (1) return
  local x1,y1,x2,y2 = DETAIL_FRAME_X1, DETAIL_FRAME_Y1, DETAIL_FRAME_X2, DETAIL_FRAME_Y2
  line(x1, y1, x2, y1, DETAIL_BORDER_LIGHT)
  line(x1, y1, x1, y2, DETAIL_BORDER_LIGHT)
  line(x2, y1, x2, y2, DETAIL_BORDER_LIGHT)
  line(x1, y2, x2, y2, DETAIL_BORDER_DARK)
end

GAMES = {
        -- START GAMES
    -- begin apples-and-banaynays
    makeGame(
        '/carts/apples-and-banaynays/apples-and-banaynays.p8',
        'apples and banaynays',
        'apples-and-banaynays.p8',
        '❎ swing sword\n⬅️⬆️⬇️➡️ move',
        'revenge has never tasted so good',
        "◝○ネ◝oル✽い|のUュ◝#⁷(•ユよ$@ニナ◝⌂□c😐◝しアけノ○ニらに2ハI0ᶜAら゜なよラホ●%◆$ハ!ュのユ⧗ネ➡️しん⁙●aチᵇ?▒★⬇️セ◝?っᵉ;エュ◝¹ヌッ◝⁙タク◝○きム◝➡️ン○ルHュ゜ヲか░◝✽ナ◝?ユ◝◝◝も=ユwᵉ◝4ヲG8っよラ❎▮ラよネ'◜[★◝。●?░、とれ◝+ヨG⬇️c▥◝エ➡️░?るˇ}◝こ1ュあモ○わ◝◝エア▥f#◝c⁸Jrッ゜sハ█◝Wヒヒノ◝ヒュょユ◝³_8ねろ◝たるん•◜g1み\\Lユ♥ニW1◆む⁸ン;{◜uス3⧗◝♥ヌW゜9`ヲ{ヲyGケユ?ナヤ、わ▒をフ◝➡️んo| Nラ○ˇ♥☉ろ◝サ¹ョぬ$ニ◀リンか⁸ヒ`$i◜▮>ュᶠ🅾️³ゅゃᶠJ◜゜Jゃきヲo웃◝³かヌん|ユCNよ`Iᵉ■◜ᵇ?ム:ュ\"ノ\n◝か*◝4ヲトゃoニ◝◝◝◝⬅️\000"
    ),
    -- end apples-and-banaynays
        -- separator
    -- begin kaiju-companions
    makeGame(
        '/carts/kaiju-companions/kaiju-companions.p8',
        'kaiju companions',
        'kaiju-companions.p8',
        'mouse,⬅️⬆️⬇️➡️ move cursor\nleft click,❎ pick up / place eggs. press refresh button',
        'breed miniature kaiju',
        "◝○ネ◝oル●ᵇロ2M\\,lヲ゜⧗…AヲSユ○「みる_る⁶ンい⬅️」~➡️+ュM●♥かン゜っヲwと$ャ?ユ○▮セ$り◝_…░◝u@lュにI★「ャ○♥◝?ねわム◝o░◝7ホ&セノ▶⁷◜?_\"³Iヲれ◜O|ラSお'ュ◝¹ᵉなロ➡️ウˇ◝セラ]マて⁷v ヨ?ょリ%Oか●ネヘハリ◝ソヨ▮めナy|、◝;{#³◝◝▒◝○り◝よqニ○や゛i&ュかKL,ュナzヲか、んケり?R~⌂DモJお♥○ヲY~☉ュ,よラ○ネ◝_$る◝Ypっ◝;*ょ◝_ナ◝◝▶\\◝◝🐱◝◝◝▶pナエお❎ュかj3ネ%⬅️Cさミ⧗゛んっ○yなオた6o4yyᵉネミ🅾️ワ#◝%!♥…cGs@ᵉンrヒんっ◝◝◝゜ルッさ゛ンキ}_◜pナぬユネへ。[stい?へン゜まろ.;6=|くク\\I◜⬅️ナ…Kス!まム◝▮ン◝◝◝◝_"
    ),
    -- end kaiju-companions
        -- separator
    -- begin hot-dog-lizard
    makeGame(
        '/carts/hot-dog-lizard/hot-dog-lizard.p8',
        'hot dog lizard',
        'hot-dog-lizard.p8',
        '⬅️⬆️⬇️➡️ move',
        'get that hot dog!',
        "◝○ネ◝oル웃シわン◝◝◝○ˇ‖ン◝ᵇね◝○a◝れLる/ロ?チ`◝○!⬆️゜R◝7ヌ⁸ネ○-!ニ◝゜⁴れ◝○ナ◝◝◝◝◝◝◆+"
    ),
    -- end hot-dog-lizard
        -- separator
   
    -- begin galaxy-tweet
    makeGame(
        '/carts/galaxy-tweet/galaxy-tweet.p8',
        'galaxy tweet',
        'galaxy-tweet.p8',
        '',
        'a tweetable galaxy simulator',
        "◝○ネ◝oひきワ◝◝○⁘◜ワ웃●◝uらり⁵◜♥ナᶜ⁷◝G🅾️ユCヲ?✽_れ◝かナ○」なpヨ?\n	る/ニ,ュᶠる_³◜Wナ7ぬp♥◝Gh\"	A@ヲ?e◜\r□ト█◝Cヲ	░⬅️_れかニBま\n○░ユ✽○\nGヌ_~ナ|bヒウ|ニシp⁵ナ゜;ン-☉➡️/Q●😐ろᶠ웃_□/ニz&ょむ $ヨよス★sᶜ⁵ox🐱ユ❎ツaCムE★mC◜ソ822エ⬇️ヨ³✽「~	まら▒ろ?ュ◆@³⧗$り⁙り゜ニgお▒A□¹OヒIB~‖!!ろᶜ0<r✽░;\\ニᵇ「xᵉ▤ぬアヲめ1み□ねI<セD゛$◜ᶜG▮★■6Iンめり▒B◆EをbbD'ウ⁸ン✽'■2⁴Hbᵇ▥■りり_4░のIr$Iキナ…/ュょ‖•∧dれる◝ <\\░ねL3□◝゜Ibᵇる!よ✽◝\rニ❎ユ、■□□なアˇ8.⁶	▶□ᶠ:ュ³ウ0█XCの4⬆️よ⁸Oヒ■H\\⁸ᶠ8れるら7|▤…@ヲ1ュf/○█⬇️ユo&Hュ■◀🅾️2_ヌ❎ア❎ヲeI◜?@ヲか░#ュ?る□○▒◝□◝○&チえヲ!$ᶜュKる9aKJ\"る◝%ュR#れ◝◝\r◝e◜◝?\"ヨよᶜᵇ?●◝Uらかュ◆る•◜▶ニ◝▮~⁸◝Sp⬇️◝o8る◝84ュ◝E",
        true
    ),
    -- end galaxy-tweet
        -- separator
    -- begin hypocycloid-tweet
    makeGame(
        '/carts/hypocycloid-tweet/hypocycloid-tweet.p8',
        'hypocycloid tweet',
        'hypocycloid-tweet.p8',
        '',
        'a tweetable animation of nested hypocycloids moving within each other',
        "◝○ネ◝oル⁴ヤフコろ◝Aヲ◝⁙⁙◝◝¹▥◝○ユl■○░◝か⁵\"|X★◝゜S▮v<\"ラよK=ニろア◝+BあJヌ⬆️◝Y¥っうv@さ~oめ▥5⬅️]た[░◝C4<웃gxEせ~エ:ᵇニG◜'たノ▮~▤ノ❎アト4s❎★y◆R◝●\"レ█³たJW(~ᶜ?⁙•イ`●◝RG゛◝ˇん➡️Cン+ナス8S◝セる?;²Uも|y$◆⁷ねトT゛_マヌWャ+⁷●3リ?ヘこ◜ゅネエ、~ノせlノか、🅾️T3oᵉ○ハそ4ゃニ◆\\NN❎⁘◜」5レょ\n」○░ヨ:□♥ミxむミユ\"ᶜ웃ラ)~■]ᶠ%◀Bヲwこュね>⧗ヒイフᶜGヌ1<9ュqムソ➡️ノqま🅾️0゛ˇ▥³◝゛こ>ᵉYh゛ニか<~█Kノマ♥トr➡️ょ➡️ッsめ\"か▒+ヨ○ノイネ…゜R_ᵉG.oオ<G~ょフp@ヲE~カ+◆⁵Dl,S;sっ゛n²▶ヌ@れみrっᶠ•○セᶠえ⬅️<の⬇️_ラヲ❎ハユ\r$•▶Gfyュ⁙&Q😐ノ웃&■◜3ュC+cな웃R‖~ゃフヌトgょヨ▥⁷ydみTヨC゛?✽ムるゆa@🅾️の。웃○ヲシs!13゜▥3♥♥かラH□⁴ュ ◝/あx□G&;ヌ◝▤zRM	?$おアエナH4⬇️゜まヲ•▥ウ、」²😐◝g8る」ウアヤニMュQけナ○▮🅾️ろ_ッ○ノせろ◝,、웃◝9⁙⁘ュよ9Cれ◝oまント●よる◝◝◝○³",
        true
    ),
    -- end hypocycloid-tweet
        -- separator
    -- begin frog-teleporter
    makeGame(
        '/carts/frog-teleporter/frog-teleporter.p8',
        'frog teleporter',
        'frog-teleporter.p8',
        'mouse aim frog teleporter\n❎ play again',
        'teleport all of the frogs away before they overpopulate the earth',
        "◝○ネ◝oル▒いHョ◝゜ᶠユ◀□◜ᶠ✽●0n◜せュ◝◝🐱ュ◝◝◝よBャ♥S?~❎か•r.ュ_%r▮◜に🐱⧗■り◝な□○っ&ンか!ュW★◝▶よ🐱ユ◝ニ◝@ヲ_░トC	◝◝²<;∧○2よ♥⧗P◜¹◝⬇️ユ⁷Iュる◝➡️◝◝◝せ⁸Oヲ◝✽ほ∧、Kラ◝ヒ\000◝;^FbIラにナᶠり⁙ユ✽░◝g-みアへY★◝2○s²ナ◝▤⁸▶$░よ□?ょ゜♥☉トら▥Hヲワ\"へョcるめ-∧ノト⁸ンん░W\000ュ,&~ニ⁷.¥□□□ᵉ\"□_ニ◆웃ミソ\"웃%ね$∧ノひ⧗よへハ¹\000\000ナ○⁵おユ⁙◝#をり•□□◜?ニZ★に★X□KラよY★♥⁙\000ら◝⁶<れわイ◝░qユKHヲ○░░░Tノ♥JbI◜▶KbI,Iヲ³\000◝ᵇ\000\000▮n.◜⁷ュ¹¥おユ◝\nᶠト★、KラよZ★_8ら◝\n、<😐1◜G😐▒⁴4ュ◝Bるな$★、Kラよ[□K²"
    ),
    -- end frog-teleporter
        -- separator
    -- begin cannonbubs
    makeGame(
        '/carts/cannonbubs/cannonbubs.p8',
        'cannonbubs',
        'cannonbubs.p8',
        '⬅️⬆️⬇️➡️ move your plane\n🅾️ shoot bubble\n❎ shoot cannonball',
        'shoot down enemy planes with hard or fast projectiles',
        "◝○ネ◝oルヌ+ムョ◝◝◝◝ヤ⁷░◝○P\000◜wb•ロカユよはて🐱'こ ュヤR◝○!fヒ○ᵉ★ヲ◝⁷¹◝ャP◜エ⁵░◝sXニ○ᵉ、ナテ🐱ュ◆⁴H\000◜エ³▮◜フ✽◝}ヲか[ヲ_フオ$2'aナかケ_GW1もあ…¹ワカj◜ヌ▮웃sけニ▶◜ᶠラGヘ★ュ◝⁵,クろ◝: ♥➡️◝レるヲ◝³웃◝◝◝w3ュ◝✽■ュ◝✽っ◝か「みり◝⬆️゜Fユ◝▶²る◝ゆ░✽◝O<◝ハy\"ヲ?-ゃにIユ○ヌg◜Wニ◝ˇZニ◝。□を◝タリ◝◝◝◝く\000"
    ),
    -- end cannonbubs
        -- separator
    -- begin tile-isle
    makeGame(
        '/carts/tile-isle/tile-isle.p8',
        'tile isle',
        'tile-isle.p8',
        '⬅️⬆️⬇️➡️ slide tile\n❎ start a new game after winning',
        'shuffle the tiles to reveal the map of the island',
        "◝○ネ◝oル▶x¥🅾️タ.れケ◝◝▒fあ゛Oの<♥フr].フハ\nW\"dXゃeんsゃ⁴そ.キgみp➡️そ>ミ▒p▮ノ▒p-c$Iッんsニむ⁴`6I…a$ ✽■るiD★N<G★⁸▮ ,`めそ$³dP■⁙ˇX★$▒#`Lウ✽fは░$\000df★☉LᶜぬオニKr、9◀2\nょ■>[²2B▮	み⁶⬅️ろ⁵➡️E□➡️ˇえYrJ\"H@@ヘ\"b➡️$んdぬ ムウ❎K>らdᵇ/ヒも◀D⁙\r	▶ロおᶠせ⁵;\rネ「 %d\\ラˇᶠ[e▥>エ∧\\お\\K🐱◆\000😐にイ⬅️,ョRヘヨ★まヒ<★-ン¥ャLッっけうせ▤<サ<トけAミし\\…░\\g²めX,ゃ²∧⁷MpT…p▤た.nエᶠ?ルnbは&ん🅾️ょsさ[なE□M²D\000∧ミノˇ⁘ヨカGミキワ▮9^なン8ヒ♪リ'#❎ヤᶠエcシ⬇️ヤ{d'{ラI゜メネしカてんshh∧t🐱d;ydト{tョぬら )ふ7\"3uトお゛◆ユ。•ぬっはろ➡️iい(s⁘オ゜\\rっsねE^vをニM\"りムしかe2て?⁸▒,ˇZゆ ◆Z&の'り➡️D☉ゅわ➡️⁴G🅾️うぬ$ぬア'░`…*スカ.⧗を3¹L🐱#&s(🐱	C★X%♥¥H▤⧗³웃░F⁴ク゛dx\"!∧ひA★Hさᵉ{KニY26¹J□Ip░E$の☉★…3$⁸\\▮¥█<웃%☉スぬ,★Yへ▮ラ░⁸Nり1I□K⁙F゛X$G\000の▮き	_¹こ□あ█'	⁴,8²&AるHd▒<キ!8░…🐱`p 	I「Bゃr8◀∧H9v☉…ニ`⁷\000░+Yd4ん3い>i◝7ゆ゜\\ラYな/ゅa🅾️³aT~ゅ{⁵p⁶ヘ★ろ!へ<³4ノ\000○=ミねネ…\n⁵ノ!つla✽トr░…゜}ゃr░#ナにっ★%2 \"⧗しS!²lル7J⁴C□▤CDfA@ᵉ$◝⬇️&□スさ❎Sᶜ•	のヤよ⁶♥Hっっᶜ!ᶠ★4ヘね、○1な⁵ホ%♥と□つカ>ゅロ▶xI}キk \"	りqnヨ❎ュら、ん□★▒てんコすすよゃ➡️?ュクd➡️ノゅ	ゃpョˇょにすセ◀x☉お~8の゛~ケᶜ○ノ☉E▮ヌゅ➡️6Wるos&っ<[eツ⬇️,れeO∧|⁸ユシヨ4▶mハqqわヨホロ|yム◝ノチモをKるYフらB★T◀に#yむ?へX🅾️4みd♪⬇️D●¹	⁶🐱1る⬇️も⁴⁶わ;hBJ⬆️せカ⬅️⁷FO░nれ🅾️ケ'「{@eV⁸EH^	ヨナぬq▤█x☉'8🅾️⁵ニらオD∧。の-エこv✽⬆️そfヨ◀	A\000ᵉ、トY bイ」$P⁴ヒ1∧⁸2⬆️▮」★>ゆd➡️PbSr>★⬇️I:²◀ら➡️ろdᵇラゅクd♪IのD🐱m□HっB@d!($➡️ノ1▥\nそさ♥⁵{⁴\nる⧗Q!サエ|\"$2c•」ニ⁸¹るXXX▮お\"\"q…#¹ニ/*◀bY$さ░゛トI… Dヲ♥g…h…dX⁴★x\000L░/`ら▮j\"D\"`$⁸a!く>"
    ),
    -- end tile-isle
        -- separator
    -- begin digital-countdown-tweet
    makeGame(
        '/carts/digital-countdown-tweet/digital-countdown-tweet.p8',
        'digital countdown tweet',
        'digital-countdown-tweet.p8',
        '',
        'a tweetable seven-segment display countdown',
        "◝○ネ◝ot…ヨ◝◝ˇ😐⬇️q1ᵉをわ8d、ラよ∧khBヌH,、	웃#,、	ᵇ\rxヲ◝◝○\000ぬPをわ8「▶ネ`、ュ◝♥く	ニH,q$$🅾️ろ□GBヌHナニ◝◝◝¹らB」▶ネ`\\😐Cをり◝あ⧗◝5◝◝◝◝◝◝◝☉¹",
        true
    ),
    -- end digital-countdown-tweet
        -- separator
    -- begin rainbows
    makeGame(
        '/carts/rainbows/rainbows.p8',
        'r.a.i.n.b.o.w.s.',
        'rainbows.p8',
        '⬅️,➡️ aim turret\n⬆️ fire turret\n❎,🅾️ cycle through colors of turret',
        'defend yourself using the radial anti-inbound non-ballistic offensive weapon system',
        "◝○ネ◝oル³eも⬆️ョ◝◝◝◝◆⧗ュ◝♥&リ◝▶キ◜◝○\000ヲ◝ᶠ\"ュ◝웃ˇ◝○`*ュ◝✽、⁷	◝○▒?$Tユ?ょュらCヲ?Lrb★/qユ◝ぬユGヌネナ◝ねさ?ノy◜◝よ¹I◜にナtqョoM8ハ◝$ニ_◜Oッ♥◜□!◝⧗ケ◝ ゃ◝G◜⁷ナ◝◝SI★◝○ ➡️◝よ…`◝ャeり◝゜hア゜ナ◝そル◆█◝◝?…◝◝◝Wᵇ◝◝ト▮◜◝Eヲ◝◝んユ◝◝◝+ヌょへmリmタへセへ◝]。んs░+ュ゜。し😐ラよひ◝="
    ),
    -- end rainbows
        -- separator
    -- begin hello-world-tweet
    makeGame(
        '/carts/hello-world-tweet/hello-world-tweet.p8',
        'hello world tweet',
        'hello-world-tweet.p8',
        '',
        'hello, world!',
        "◝○ネ◝oてセヨ▶'/ハ○わ」N█◝▶oxンᶠュるまン⧗゜xヲ1うナ`ュら◆ュ³~ヒ○ろ◝█'ュウ◝▒+ュ_ン♥○ン5ュろかュょ_ニヌᵉ◝ラ•(?ユ/よラᶠ?リ+▮◜ハ`ュNら▶^◜_ᶜュわ◝😐#<ニヌ○ん■◜ナ◝ん○ュ゜ン!ュ	◜゜う░よ▮◜ᶠュ_▮◜◝◝ ュ。◜Oュᵉ◜◝せ░◝○@ン◝▶ニ○Iヲ゜ユヨ'▶ハ▒やロ○へ◝◝◝◝◝か<",
        true
    ),
    -- end hello-world-tweet
        -- separator
    -- begin math-abcs
    makeGame(
        '/carts/math-abcs/math-abcs.p8',
        "math abc's",
        'math-abcs.p8',
        '⬆️,⬇️ navigate menu\n❎ choose answer',
        'test your math knowledge!',
        "◝○ネ◝o,ん◝よ		\rよ░7|ニᵇハ○エ◝よ⁸◝◝◝◝o)ュ◝웃ニ◝Oユ◝'Xヲ◝⁙れ◝おラ◝⁷まるる◝~\000◜ほ|,ュO♥{ヲかラんユ?ハ▶◜よュ⁙◜◝ろユよノ'◜かュ▶◜◝ろユよネG◜○ニ_◜_ュ◝◝Hヲ◝◝◝◝コニ◝Oユ●◝◝_ナ◝ア◝◝	◝○bヲ゜リラ○ヒ◝◝█◝◝Oナ○イ◝◝ナ◝O\000"
    ),
    -- end math-abcs
        -- separator
    -- begin paybac-man
    makeGame(
        '/carts/paybac-man/paybac-man.p8',
        'paybac-man',
        'paybac-man.p8',
        '⬅️⬆️⬇️➡️ move\n❎ shoot\np pause menu. allows selecting 2 player mode\nesdf move (player 2)\na shoot (player 2)',
        'live for nothing, or die for something',
        "◝○ネ◝oル▶◀ルつT²ミセ◝◝エに😐d◝ャゃ~オ\0008@\000▮゛F\000ユタzPx🐱Bるワ\000B●よるᶠ😐³4ュ_\0002(░P9x⁸よJ\nニ¥ ュ1ナ◝³゛ユ◝ヌ◝むフち\\ト◝゜X&ッよワ<ンラ?G★ヘ◝ろyリよ✽ミuヌ○れC	8ルヌ○□=d#ニr-1◜゜➡️C6ヨᵇ⁷◝♥qおゃン⁷◆ナ○`Iロ█?ま●◝▒⁸✽✽゜ム⧗◝わオ웃♥よる◝!3H}よユっ◝れゅa$vラユ◝	➡️ナ`ヨq⁸◜g⁙るᶠRャ◝░∧ヲノニ◝‖🅾️p■◜かうL⁴ュ○	GBら◝◆つツの「➡️ら◝♪ょI⌂🐱█◝コ◀ツのDJイを◝)<⬆️p\n◜?➡️$,rゃ◝✽_🅾️😐$ゆかも7!T◜	ねろ」ᶠヤ 7⁷◝♥ろ「⁷ᵉ▮ハM(にュ⁘>+くこ8=◝゛░フ█(ュ∧ヲ⁙&セᵉa•♥CBえコ⬇️ト▤³□³▶G&■1ュっr,IアリろQ⁶G█ネニ ュ9OᶜE0i⁸@웃たイか5{;🐱r□っトニとC.■Nをよニ、Nx>Kノヤア⁵テ「ふQaヲ;S❎dw,テタユo519eテセᶜ⁸⁸ᶜよす」ムᶠ,さ0をエュ▶ャ●░」~チ-よY\0002,⁴ウ⬇️_².゛◜(さ`?<ルᶠ<チ░‖XのE◝z❎゜V\"c▥メ■•⁸ˇ웃Dハナ²	¹8◀り#…ヲノ☉5<<Iᵉ$ソ☉7H😐Nᶜ<★FDBHヌO★「]ヌ²GヲA○s◜0\\ュiよ/4<B◜ネ○…8xノO"
    ),
    -- end paybac-man
        -- separator
    -- begin toxic-toads
    makeGame(
        '/carts/toxic-toads/toxic-toads.p8',
        'toxic toads',
        'toxic-toads.p8',
        '⬅️⬆️⬇️➡️ navigate the grid of regular toads / move the toxic toad around the outside\n❎,🅾️ when a regular toad is selected, rotates clockwise / counter-clockwise\n❎ when the toxic toad is selected, infects the toad it is facing',
        'infect all the toads!',
        "◝○ネ◝oル⬅️え:`ュ◝◝◝◝■😐◝!□ろろDさ▤▤⁴	ラ7O█cっ■🐱#ユユはh。🐱D8■るJュ?ノぬ○ン_e★C`█L2◝7³a▮Fら▮ゅヤ\\9░12░ヨ◝o「◝QB9'&A🐱☉⬆️よ…Y▮をほ✽#ユD🅾️ユエんそ웃8⁴゜r☉てろ◝▥⬅️◝GFb	웃7ˇアᵇ³~J&K ★😐ᶠ²⁸%😐◝▤c😐゜⁸ネ	ネ?◜\raュO(&&く☉⬆️❎ラ▶2つ✽# ,r░にろヲ⁷トそ!♥tアc\"よLヌ▮ヨ◆もュよ⁙□I%は ⁙¹ユ&$◜J&K⁶²d★⁴2^$Iヲ+■G	c😐ヨR◜♥!ニハ゜⌂웃I… &&\"%⁘、う♥せWRM。✽'²G…ネ▒Xノ⁸Wと❎ネyᵉはCスゅ!H░o、゛⁙ン웃ま◜\000⁷よユミ★っ#9$リ&★☉0 	웃\000ナ{ク+な▒1⁸⁵「●…ゅ★@をᶠQ🅾️ハ▮&W⁸c░2をイか¥エ■.ン$ニに▥Ihふˇrdb\"Vpユシ□🅾️³░゜⁴□\"GxるOス▒けマ0け⁙■웃░◝◆◜@ひD◜Wたさ◀さユe★	ᶜ\000█◝ᶜ$は⁴、█@a😐ヨ_ᵉa2を‖る「くュっ゜Y゜ユ$IHHヲ♪□Zk▶	Eてナナ/さ◀░イキ⁷b➡️#<ニか◆Q⁙ヨ⁸ラLヌ■➡️◝よ▥…XB\"² 	웃\000\000\000~J&K ★ᶜ2🐱$	d😐ヨ_☉🅾️1F(c░ラ゜◝◝◝トᶠ"
    ),
    -- end toxic-toads
        -- separator
    -- begin simon-says-tweet
    makeGame(
        '/carts/simon-says-tweet/simon-says-tweet.p8',
        'simon says tweet',
        'simon-says-tweet.p8',
        '⬅️⬆️⬇️➡️ activate a section of the board',
        'a tweetable simon says game',
        "◝○ネ◝oル█!ニ◝◝◝゜フノ◝ょOュᶠン♪ユ○ᵇ◝ラ○ヌ_⁘◜GニOᵉ◜゜\000Gヲ⁵@ヲ_Hノ○ 	◝³➡️そナ/@□ン○$I²よ\r!●かC★ュい8dュi=`○'³ス◆&ム ラg■‖る○#A\000~チて⁵ロ❎ハ\000「?F^ンQウ$よ%■.っ◝#ゃ_ a!ュ#◝░○😐ュ ?●7ゃ゜ラょユかュ…ノNュ\"ノᶠン/ゃ)?\r◝か$❎ュ%ヲ゜%9ノ○かdラ◝ᶠ★…◝◝…ヲ◝⁙ッ◝ヌ_さ◜Oュゅる◝☉?9る◝'ゃ○r✽◝ᶠよq●_□○ヨ▶wヌᶠ★ヲe\"ニˇ?★ュO∧$$、➡️○る➡️ヲY,░#ッWけv%ン+v░ケヌに$ほュを#웃ュ▥「PノG░⁵ニOろ0ンヨ「$ロワ■⬅️@◜😐⁵ロ?Xの$ャ9D⁴ナよ I★ュᶠろ█よ⬇️ろヤ⁵ニ○…ヲ?ᶜ○♥⁘◜゜ュイる◝☉よ🐱`ヲ_ヨ▶Gヲよ➡️る゜ュ?れᶠ░◝◝◝ヤ⁶",
        true
    ),
    -- end simon-says-tweet
        -- separator
    -- begin bb6-champion-tweet
    makeGame(
        '/carts/bb6-champion-tweet/bb6-champion-tweet.p8',
        'bb6 champion tweet',
        'bb6-champion-tweet.p8',
        '',
        'xxxx',
        "◝○ネ◝o、゜@♥ほˇス◝◝◝い✽◝?ねア◝○Hワ◝'rム◝?ノ█◝よ…<ヲ◝⁙な◝◝\000ョ◝•ニ◝Oス◝よオ◝?!◝◝▒◝よね'◜◝³◝○Bる◝◝▶$ユ◝▶★ナ◝?ろユ◝◝ᵇナ◝Oユ◝ᶠス2◝◝り⬇️◝◝ナヲ◝•🅾️◝?@❎れ◝よっュ◝♥ア◝え⬇️◝○!◝○るる◝?▤ヲ◝ᶠュ◝◝²ニ◝◝ᵇり◝◝゜てヨ◝゜ヲ◝⁙□◜◝よ ⁷ュ◝✽ノら◝かPュ◝⁷◜◝⁶ニ◝?░◝?■わ◝○☉✽◝よ ◝○#ュ◝ᵇャかsヨ◝'6◜◝れア◝\000",
        true
    ),
    -- end bb6-champion-tweet
        -- separator
    -- begin firewall-fiasco
    makeGame(
        '/carts/firewall-fiasco/firewall-fiasco.p8',
        'firewall fiasco',
        'firewall-fiasco.p8',
        '⬅️⬆️⬇️➡️ move\n🅾️ shoot firewall blast\n❎ start a new game at game over',
        'use the firewall to hold off the malicious programs as long as possible!',
        "◝○ネ◝oル゛ᶜMヘbめトH□b➡️◝5⁷ヲかリ◝7□◝◝A◜◝セ⁴ン◝⁷■ラ◝あ ○Mュエ²おア⬅️ユ◝²ᶠニ⬆️っ◝KDるり◝Xるqオッよ⧗Cケに∧4◝³レ⁴♪t○Jヲ゜dヨlのュエ⁙□dュ:ヨ?▮²…トン゜D\"*リ◝#i゛]²ヒユ○ノI$Hナ○くICB9⧗8★⬇️◝ᵇ_け웃k%ニ◝G⁙W…-I◜/Kt8웃6。ン◝pD^Yるの✽◝」8Yj□◜ん⁙Oヌ○-゜rヲかKら◝テけ➡️クsノJ|ネ○C☉ᵇWおフタリンコン⧗⧗リろ<	リョめミ{ゆ+▥みスツフョ⬆️かは…d▥iイ□▶サフ;ルフカ?lvリ?ニ♥T<j_゛9ルよう⬅️⬆️L¹░#9ニv●゜⁙O&◆ChJヒᶠ◜ハヌヌIる➡️た◝ᵇる゜、¥□◜7🐱⬇️◆▶ュO➡️8⁶1Y◜か🐱エ$る◝おH$ュヤ⧗	ノ◝\r$웃ニ◝ᶠ☉'8ュに⬅️▤れ◝゜Hこけゃ➡️◝5S★ユ○_⧗ラワZノ_0▮IヌOe◝ᵇろ\"ニ_ン゜█0◜⁷ュ゜²6ュ*➡️◝Q🅾️⁙◝○▒◝○Aる_★E◜O□ゃ⁴みMムO★ノ‖!⬆️゜「◝こニ	?ヨよるl➡️スᶠF~]bXさ³&ニ○ま$わbニ○¹"
    ),
    -- end firewall-fiasco
        -- separator
    -- begin shuri-ken
    makeGame(
        '/carts/shuri-ken/shuri-ken.p8',
        'shuri-ken',
        'shuri-ken.p8',
        '❎ throw shuriken\n🅾️ jump\n⬅️,➡️ move\n⬆️,⬇️ throw shuriken upward / downward, when throwing shuriken with x\np pause (allows resetting after death)',
        'fight star ninjas with ninja stars',
        "◝○ネ◝oル}:オひjlxる⁙おユ░'<ニ	ᶠ_⬇️◝よ…\r◝○aつ◝◝…、◝○▥ユ◝▶b▶◝○れ......🅾️ウニ➡️░0ᶠBBヲH⁸゜	➡️⬅️゜◀◜◝³◝cみまままままままH⁸ト!☉|$░◆░ユw2<みュ?•、ニスヌ◝c▶38B😐さ」▶▶▶▶ᶠ゜ねヨヨユヨユト&]★◝yヌ◝○.qユ◝🅾️✽◝○…ミ ⁷◝ミc	◝クpリよチgゅうュ?はdヌ○に◝#やままXお░⬅️⬅️⬅️ょ□るGBそ😐░ユ➡️▮◜◝◝⬇️⬅️⬅️⬅️⬅️⬅️⬅️⬅️⬅️░ユ➡️▮>□るGBヲ◝◝ᶠ........゛>゛>゛>゛◜◝◝○웃◝○■おユ░'<ニ	Oxるれ◝ト2ュNヲら◆ラ◝◝\rッ◝◝◝へ웃◝?り◝?ゅュ▶2ウ◝ヲゃ◜⁷²\000\000█よノ◝/5Hニゃ'!!ニ◝³をwユ$∧ろ★Hラより1らこルO"
    ),
    -- end shuri-ken
        -- separator
    -- begin northern-corridor
    makeGame(
        '/carts/northern-corridor/northern-corridor.p8',
        'northern corridor',
        'northern-corridor.p8',
        'mouse move the cursor\nleft click activate a lever',
        'you must decipher the locking mechanism to proceed',
        "◝○ネ◝o、゜(ノ「さヲ◝トᶜ◝◝¹ュ◝⬅️ユ◝ᶠ「◝◝\"ュヤ9ヲ◝▶ニ○ウわ◝よ⁸◝kN◜◝Eヲ゜sリ◝/る◝&ヨ⬅️ュり/웃トる○░&~Iュˇ⁴/ᶠ?⬇️◝⁙'◝K◜ヌ◝るᶠュ‖~ナ◝■ᵉ▮pユ◝/る◝🅾️?ン◝▶ニ○をよュ/	⁸⁸\r◝+゛◜▶&イ◝れ◜ネはヨつュᶠヲ◝▶ニのよy@@@らりわ◝<ュOヲかユ◝/る◝🐱◝\r◝#²²²²Bれ◝█♥◝○り◝🐱よン_ヨ◝/るよュエヲ❎◝◝◝▶ゅ🅾️Eゆx◀ンヌZノ⬅️g➡️;🅾️♥'お♥'な♥gマナ😐}4ロカスGc゜かョbよス/ロ◝◝はニヌ⁸▶Gま8るわた8ヲ8ヲ8ヲ8ヲ⬇️ヨ2^をょヲE~➡️_ノ▶ン◝◝○\rOま	7ニ&ュれ◝よ⁷"
    ),
    -- end northern-corridor
        -- separator
    -- begin dimensional-delights
    makeGame(
        '/carts/dimensional-delights/dimensional-delights.p8',
        'dimensional delights',
        'dimensional-delights.p8',
        'mouse,⬅️⬆️⬇️➡️ move player',
        'explore the great unknown of the ice cream dimension!',
        "◝○ネ◝oル♥ᵉ♥⁙ちんケ◆H`▶❎]\\\\\\ろ²!。I8らᶠ😐🐱゜「▥:²•「☉きニaュ⁙b?ユ2□ゅや&◝%ゅニhあ#5FムニA⁸W▤ネゅ!9😐cxBるぬフむ🅾️\\セねpI,エ🅾️ユ░'<ニ	エ、&!ュᶠ。|と#_	|!⬆️PB	%ひ、9け▶▶▶▶▶▶◝○'■J(く░□J(く░%◜◝D★'セ⁙おユ░'<ニ	○ヒも◜…◝kヒ○i▶_キ◝%▶◝◝◝◝ょわ◝う⬅️◝?ム	◝◝ 2◜ワsン▒◝-◝◝🐱○(◝⁙ヤん?セ░qヨこ;み=s=Kラ-●セ◝ ワはケ■シ/ュ◆rまハ゜◜?Oなフ☉か3	◝⬅️9゜ュ◝³\"?ょ◝◝/スe◝s.~w░◝○▮を◝~ヒ⁷◜ほラ◝/ノ◝◝▶ruI~∧⬅️かしうュれ%?ミ◝◝◝いrヨ?フヌ◝◝◝○¹"
    ),
    -- end dimensional-delights
        -- separator
    -- begin snowman-simulator
    makeGame(
        '/carts/snowman-simulator/snowman-simulator.p8',
        'snowman simulator',
        'snowman-simulator.p8',
        '⬅️⬆️⬇️➡️ move the cursor\ne,d increase/decrease size\ns,f rotate clockwise/counter-clockwise\n❎ place / select object\n🅾️ cycle through tools\na cycle through tools backwards',
        'do you want to build a snowman?',
        "◝○ネ◝oルニ3っッ◝/ニワユgヲ-ュ◝んユ◝◝◝ま⁙▒ュエれわ◝Z^◜んラ³◝kCら◝▥eY(◝Wなひニ◝⧗ヲˇG◝/ロSノけラよふdるる」¥◜Gm★³➡️エ◜♥\"▥0◜7!ニ▶3⁸ヲ◝スo1ク⁸ハ○•◜ナ○ゅOュ/ハ7◜◝むニ◝ア)/◝?9ン=ヨ?\n○タ◝█kニ◝,゜○ハユ◝゜ら◝)リ⁸.yヲ'ヨ+▶◝⁙ャ5sqラ?😐ュん◝4ヨ✽゜□○♥Cなオpヨっ❎ヲ▥◝‖◝&◜ハ◝%◝◝🐱◝◝/❎◝□よラ゜◝ヨ◝/ヲ◝•ニんユ◝○れoニ○「~²◝んユᵇヲ○●゜ら◝6|ニ○Nン◝◝さ♪wま♥⬅️つ█、 aニハ○ア◝○\000"
    ),
    -- end snowman-simulator
        -- separator
    -- begin unsigned-hero
    makeGame(
        '/carts/unsigned-hero/unsigned-hero.p8',
        'unsigned hero',
        'unsigned-hero.p8',
        '❎ attack\n⬅️⬆️⬇️➡️ move',
        'fight your way higher and higher to the 255th level of the dungeon',
        "◝○ネ◝oル-⬇️ク。$■□□□□□□□□□□□□□□⁘ユ◝゜●◝?@ヲ◝ᵇ|RB	E$エ★l%⁘ねtIXE✽e░⁵aっを⁸░⁵aH2	□ムらる0ᶜく$1ᶜC(」H¹🐱█  c■6▮⁴d$B░gスオユ░|\000\rOXP8Dabp\0008\000、\000ᵉ\000⁷█a	◀🐱ろ(く░□J(く¹。…… ,⁸ᵇる🐱ぬ ,(チA@²…\000$\0009ら■…ユ☉🐱⁵れ🐱ぬ ,⁸#⁵$ᶜH 🐱●`「●a「●➡️!(ナC⁸⁸²🐱█  😐⁵ れ⁵□░\r\rO8²□█…p	░%░aユ⁷h⧗⁴$,⁸█a」░`a⁸こスヨ「」🐱くき¹。▮⁴$$⁸ロt<!I█☉pきユてHル\000²□tオ✽★P█░ん★cj3I0,、3²きA🐱0 ³…³ᵇᵇり0$0p✽く@ゅ\000る⁸⁸²\"ニ@「²².!G\"¹▮…\000ノ\000Oxる%さ⬇️3\000HX▮F\np\000($Adc░}d⁸●a「く░⁶4き⁸	ᵇ@▮▮を🐱ぬ ナ■\" C\000Bる⁙\n…¹P웃⌂\n	⧗ᶜけ⁙❎dWす」	るっ▤゛C🐱Hb#「□r$「、g「●ろ …ᶠ $ん%c²2あ\"2⁴░ᶜハ•……█ラノKhヌ		[ᵉ♥h⁶ナ	V‖⁴りv|	p⁴ナ³\000★a■!、M&⬆️DF(ニCWPみ…웃5⁸ᵇる🐱ぬ $$🐱' A☉:\"4 A⁵♥ナと$♥(,!⁸9\000□V²!\r\000「∧@⁸◀をろ∧d웃ナ¹_●➡️▮¥オ¹A@ᵉI-\000A⧗■をさ(<+□%!K█D□∧D(@▮F-ホケ⁶オら🐱\0008\000⁘□⁴らぬ⁴😐░	おくき░+⁘4…●█³a⁸G▶∧▮●p ナ□、웃'<#V$おp⁴★ユ「	⁶G\000ᵉ\000⬇️\r⁷█³ a⬇️⁴➡️∧▮VB	K●⬇️P2■⁘オユ ,⁸ᵇる🐱ぬ ,\000¹O⁴¹¹H\000□█⁴ ¹⁸	ノ0⁸⧗ᶜる🐱ぬ ,⁸ᵇ²`X🐱░`!a「●a「●くき¹。▮□⁴⁴¹A@▮▮░³✽gス⬇️オD³…\000ノAhけニ■✽ゃ♥ぬ ,⁸ネC「…ら▒⁴イfBア0ᶜCヘfBL	R█T◀H□▮■▮⁴さ\"▮²\"x░ュヤ▒✽░😐リ◝C□		X8}◝マエ😐❎○ハ◝ら◝?\000			◝に……█✽◝?らxえ◝:○⁶"
    ),
    -- end unsigned-hero
        -- separator
    -- begin pursuit-in-progress
    makeGame(
        '/carts/pursuit-in-progress/pursuit-in-progress.p8',
        'pursuit in progress',
        'pursuit-in-progress.p8',
        "⬅️⬆️⬇️➡️ turn police car\n❎ restart the game when the game ends\np pause menu. allows selecting 2-player mode\nesdf turn the perp's car (in 2 player mode)",
        "don't let the perp escape!",
        "◝○ネ◝oル+CQ8◜○…🐱オユ•◝⬅️p3ン▒ユ◝…゜dゃ^◜?ニ'ャ◝/f⧗◝■よユ■゛ョ?Lチニひ▮f◝⁷◜⁷░ゃ◝▒?⁴◝◝!ヨ◝◝リ⁸Oらム○ゃ/…かヲ?ユ4ヲ⧗ユ?キよ✽ツ░゜る_ュ@★も웃ヨラ#/¹7◝タユ☉Mn,ラ?ら\"7ニ⁷る◝▒P.ᵇ➡️⧗#ュLHニ$ュ@ヲ?▮◜◝◝○ゃ◜◝Dノ◝ら◝E◜▶9ᵉOか♪◆ト🅾️🐱P◜qHお\000くュE8ハほヒ\"<ュんイOL◜P゛Iユヨ³よし~■そラ✽◝o⁴゜?ユ◝▒ュゆx◜▥まG◜▥まン◝▶…○るᶠナかユCヌ◝■◜◝よvx²~Cx²~•◜◝H⬇️C◜ニipっ?<|ュ◝ᶠョ▒トヲ▒トけ/?ララ#◝◝⁵いュᶠぬっ◝█ユ○ ュ゜4$ュLHヲ゜▮◜ᶠ░◝◝◝トの◝?く◝g◜'ュᶠ\000"
    ),
    -- end pursuit-in-progress
        -- separator
    -- begin cool-cat-cafe
    makeGame(
        '/carts/cool-cat-cafe/cool-cat-cafe.p8',
        'cool cat cafe',
        'cool-cat-cafe.p8',
        '⬅️⬆️⬇️➡️ move\n❎ use / activate\n🅾️ take the drink out of the coffee pot\np pause menu. allows selecting 2-player mode\nesdf move (player 2)\nq use / activate (player 2)\ntab take the drink out of the coffee pot (player 2)',
        'work as a purrista at a cat cafe!',
        "◝○ネ◝oル◆{ミけ`PアEBBヲ゜ᶠ		x□										りBBF🅾️m\000\000\000\000\000\000\000\000[HHノ◝😐!!😐ス◝⌂こCB²◜♥4くBB●◝レ……0◜gAX0$░セᶠ⌂よ%lセ□□0ᵉ⁷ち?yユC\"ᵇ	」>Gそ]Ksまノヨ⬇️u&!a🅾️9★み⁵そ♥フせ▤!!\\ロ▶◆ュ6$$ナゃ$$$$$$$$$さL6□2、K\000\000\000\000\000\000ユ\00086□□◜w🅾️▶CB(◀□□□□□□□□ヒ☉l!り>っ◀□□□□□□□□□\\ん➡️んA⧗ゃら웃ˇHHHHHHHHっり\nん…qJᶜ⁙								」	ᵇ●yハイ🐱✽░░░░░░░░■6$Dる●░░░░░░░░⁘6⧗✽⁴5:$$$$$$$$d8♥⬆️⁶れDBBBBBBB\nま🐱!!⁘CBBBBBBBBヒuL$$`CBBB\n0$$▤そGP웃░ᶜ。□□□□●!!れ¥I1$$ᶜCBB²6$$$l¹ᵇ●▥,Kb!!!¹<◀□□\"ネ¥□\"aCBBBゅ▥-$$▤れ⁙の…きB♥░░░Tか⁙◀□2ロん…R「&□□□\\ンお⁷		웃😐+「□B1$$d、l!!!LにI□ム⬇️l!!!!ᶠ)●░⁴ょ▒6d!³7V\"!!!⧗░░░ᶜsうCを$●웃░░░ヘBBBるムれ0に|Yぬ…………………▮モ!!□6$$$$$$$$▤yB◀□Tヘ……………………ニ◆!し0L$$$$$$$$😐+「□B1$$$$$$$░セ5I🐱ツ…-$$$$$$$$▤ねュユ&d!#ュ█ˇHHHHHHHっぬf?もエ…♥ネ▥a\"!!!!!!!くyロ`▤Sあヨ?[◆、🐱░Hヲエ⬇️◝んB🐱\n◝AユよXH9ナ?◜'Iᶜ	ニ○ᶜ□□ユ○゛□□□□□□ラ\000							ᵇ						A}7⁙					¹							A、HHHHHHXHHHHHHHH\"!!!!!!a!!!!!!!ネ➡️$!!!!!!a!!!!!!!◆れs0➡️…………▮……………………ん◀IHHHHHXHHHHHHHHHHHHHHHXHHHHHHっヲ$IHHHHHHXHHHHHHっcモ⧗웃░░░░░█░░░░░░░<&★……………ぬ………………………………………ぬ…………………qH★………………ぬ………………▮ケᶠ゜⁙					¹"
    ),
    -- end cool-cat-cafe
        -- separator
    -- begin make-cow
    makeGame(
        '/carts/make-cow/make-cow.p8',
        'make cow',
        'make-cow.p8',
        'mouse,⬅️⬆️⬇️➡️ move cursor\nleft click,❎ grab resource\nright click,🅾️ discard resource',
        'combine resources. make cow.',
        "◝○ネ◝oル🐱#リ⌂◝◝◝◝◆█\000⁴⁸らま⁸!@らO Aら³るS▮⁴ュか🐱\000も░◝E(!Aらゃ゜░かれよナ◝9░g▮⁴⬇️ユ•◝◝◝◝トuY◜◝B:Y█◝○らヲよ'◜◝Iᵉ◝○Aる◝゜…◝◝◝◝ト`ネ◝ᶠろを◝?オユ◝ᶠキョ○ヌン[◜Oカ◝○➡️、⁶`¹🐱ニ○'?░◝uヲ)ュト、◝◝!ラ◝◝⬇️お◝O★◝り-\000B●aっ⁵ム○■🐱オBっ¹⁴░◝I(ヲ#、ナ○る◝かpュ○ノ◝◝◝)\000"
    ),
    -- end make-cow
        -- separator
    -- begin swimsaver
    makeGame(
        '/carts/swimsaver/swimsaver.p8',
        'swimsaver',
        'swimsaver.p8',
        '⬅️,➡️ aim\n🅾️ throw life saver. hold down to throw farther\n❎ restart the game when all swimmers drown',
        'save the swimmers from drowning',
        "◝○ネ◝oル⬅️わょQ◜◝◝◝みユ◝'●◝Gヌ■ュGヲ○,ヨユ'□◝⁷	◆ナ?◜イ<Aすュ²◜▶6E▤²◝ユ?キ+ュdニ◝きF#O⁘◝シNナWAヲ゜$⁴ラヨOヲよユよ☉ナ⁸?リ◝\n◝gな█◝よ▮░◝や$ᵇ◜フナナ◝イゃ◝▥•●゜3?タ゜ナん%^れOY\"%ュ▥xン-<ュIる+ヲe!Iを◝☉◝○り-G∧Q◜せニ⁸8rノ○ヌりᶠコそ>B◜'▥よ8ン◝ろpS.◜せ▥◆ヨよヌ゛◜◝²ニ◝/⁴aナ◝イわ◝XqIヲ゜ミく■ニ○k▒░🐱◝37◝Sる゜ュ◝⬅️ユ?ハ¹ᶠ◝ミまム★&ン゜⁙	◝○▒░◝◝゜HDᵉ◜んa、ニ○J9ン◝⁙ュ○ント%RH!✽░⧗◝⁷○q$yノ○1⁸゜⁶くュ◝◝よ*"
    ),
    -- end swimsaver
        -- separator
    -- begin seaside-scramble
    makeGame(
        '/carts/seaside-scramble/seaside-scramble.p8',
        'seaside scramble',
        'seaside-scramble.p8',
        '❎ select row or column / swap row or column with selected\n🅾️ rotate cursor\n⬅️⬆️⬇️➡️ move cursor',
        'unscramble the seaside critters!',
        "◝○ネ◝oル☉もセ◝◝◝◝bュ◝³◜◝○OFe,😐◝。◝◝トっ◝いQなp✽⬅️◝³◝◝トっか|ュよン◝◝/ャコ◜ナワユ❎♪゜ノ◝ゃ◝よ⁘ュ◝♥ソううr✽ねユヨ⁷ノ◝ᶠ█◝○られ◝=リ⧗おッ;せっュ➡️ヲク◀をノ⁷ン_セトュ◝◝\nふヨ♥⬆️◝•◝◝トっにラ◝◝◝◝◝ク³"
    ),
    -- end seaside-scramble
        -- separator
    -- begin hex-hacker
    makeGame(
        '/carts/hex-hacker/hex-hacker.p8',
        'hex hacker',
        'hex-hacker.p8',
        '⬅️⬆️⬇️➡️ move player, navigate menu\n❎ interact with object, close menu',
        'q: how do you defeat an evil hex? a: use a hex editor',
        "◝○ネ◝oルへ★⁵♪Gせ◝◝1⁸														²◜◝⁵◝○ナ²ュト90⁸												² ░◝5Bり◝ほp⁵ラ?Mr²➡️◝+\000 ░◝+		◝◝?¹ユよ⁵\000░ユ○%!ニ◝◝'\000◜ほ\000█▮◜に$$ュ◝◝⁴ら◝◀\000▮る◝ˇ░░◝◝か\000ヲト²\000Bヲよ★…ユ◝◝⁙\000◝[\000@⁸◝W□□◜◝!ネ◝³ユgサよ⁙\000 ⁙~うロ◝▮□◜ᶠッ◝'キツ🅾️pエリ⁸♥\000◝いルッわり⁷@&ュoうヲ!、ニ◝すrッ◝ᵇュ★や⬆️%▮ナ○kラ*□ニ◝ゅ「◝◝◜ょヘり█っ◝‖\000▮る◝ˇ░░◝◝か\000ヲト²\000Bヲよ★…ユ◝◝⁙\000◝[\000@⁸◝W□□◜◝♪ュ_」⁷っ………………………………█\000れ◝、く⁸◝タニネ◝゜…!!!!!!!!!!!!!!Aヲ◝▶⁸◝ャ\000"
    ),
    -- end hex-hacker
        -- separator
    -- begin tiny-chess-board
    makeGame(
        '/carts/tiny-chess-board/tiny-chess-board.p8',
        'tiny chess board',
        'tiny-chess-board.p8',
        '',
        'non-interactive low resolution chessboard',
        "◝○ネ◝olG?∧☉$1カ ★ろ$웃ゃ□➡️ミ□P	]h@	んる■…⁷「#⬆️✽g8∧8●RをH⁸ネ⁴%⬆️p█;■ゅ³□のpユエB✽$う⬆️QB「%⬆️■JAン◝W★0~こ\\□お$◆…♥⬅️⬅️⬅️◆♥♥$F□Oxる⁙おユ░'、■⬆️PB	%⬆️PB	◝○eニXヌXヌXヌXヌXヌXヌXヌ⁸(く░□J(く░□◜◝	%⬆️PB	%⬆️PB➡️x★\\\\\\\\\\\\<\\ュ◝◝◝/▶◝s.◜◝◝◝❎⬅️◝9▶◝◝◝◝ょわ◝う⬅️◝◝◝◝%웃➡️ろ⁙おユ░'<ニ	⁙I▮!く░□J(く░□◜◝ゅるねろねろねろねろねろねろねろ■PB	%⬆️PB	%ュ◝⁙J(く░□J(く░□みノヌヌヌヌヌヌ➡️K∧8□Gニ⁸Oまる{%█$	:4き░cニ⁸っ³😐■ゅる3、K、C)c$░q🐱□J8らえ⁸ハ¹	Y8ヲgくB□Nゅ(!😐□ゅ⁸しきュ◝+I「よQ.	ᶠ",
        true
    ),
    -- end tiny-chess-board
        -- separator
    -- begin skater-tater
    makeGame(
        '/carts/skater-tater/skater-tater.p8',
        'skater tater',
        'skater-tater.p8',
        "🅾️ build up speed when you're on the halfpipe\n⬅️⬆️⬇️➡️,❎ hit these when you're airborne to perform the combo displayed at the bottom of the screen",
        'are you the hottest spud? land three tricks in a row to prove it',
        "◝○ネ◝oルdき□ョへ◝◝◝▶ᵇ7	ネ○▶░rQ◜○(\000ハ◝ゅ◝よ\000'ヲト🐱ユ◝▶ᵉpユ?ヒ◝◝◝K⁴◝◝¹ニ◝◝⁷3あユ◝⁷f⁙◜◝@¥ニ◝◝◝◝C8ᵉゅ?ュ◆マみ\"🐱%¹\000\000よン>NャAか…pリ⁙g⁸_♪◝i⬇️◝]ヲ웃◝%゜◝◝\"ュ゜ン♪◝よ▮◜にニ⁸⁷ネ◝ん◆ュ◝▒ユ◝\rGス0◜oᶜ,ュら◝⬅️_♥◝Yヲ#、ナ○を⁙゛🅾️\000ュ○X(ᵇG█¹◝▶ᶜᵇ「#⁸⁵◝ᶠるるX⁸るゃ◝░/⬆️⁴x\000aュア🐱⁷X@▮\n¥ユ+る¹◀🅾️ぬぬ…ユユ⁙O⁸HXヘ▮¥n^モP2,<Aヲ○⁵ナ⁸),,,$ュ□□◀⁶R0⁘@xる◆ナ⁸	(⁷!ニ◝◀るX¹●1~ユ█ᵇせ♪⁵(、⁸ᵇ?e_の/ラGf⁸⁵²░◝l◀ン'⧗\0004$もニシユ●\000"
    ),
    -- end skater-tater
        -- separator
    -- begin vco-tweet
    makeGame(
        '/carts/vco-tweet/vco-tweet.p8',
        'vco tweet',
        'vco-tweet.p8',
        '',
        'a very compelling object',
        "◝○ネ◝oル🐱ハVア◝◝◝◝/E\"⁷◝トDd웃◝リユKヌ◝(まれ◝⁘ュ■∧ヲ?\nウ⁴のユ?⁙░█$ユ✽◝UヌᶜOヌ◝◀~	◝フろるいHBヲ◝▒_ヲ゜%N~ヌ○◀あヲ#ヨよネナ∧⁸#ヲトdD❎⌂L▮★ス:◝⧗とXたニI%!!レ?ゃ(|たゅ◝o\"Sるˇiヌ◝⧗「1ん😐ヤ「sし◜ᶠ▥flチ\r゛れ◝Cオ)=゛22C、ヲ_9@さんs゛♥gvル◝xてル■k¹◝7♥*ゃv-▥-ユ?2りねD(⬅️★モpD'◝⁷⬇️░つud^q…ットpx$◜█\"웃◝コ🐱ろ2◆」d◜_けx🅾️L⁵⁸◝にaっ4リu&ニ○⬆️ら❎みヲ○%◜らD□イ$ュ?「Gぬオアxヲか$る1|■웃♥◝	エへュ⁙cIュo,⁸w「ニ○わいそナ◝」ゆろ❎ヲ◝ねろ■.◀◜♥ニH、ニ◝「>Lュ○⁙IH<²ニ◝みろ▥ノ◝えhヲ◝⁷ナ◝◝◝◝イ\000",
        true
    ),
    -- end vco-tweet
        -- separator
    -- begin dragon-drop-off
    makeGame(
        '/carts/dragon-drop-off/dragon-drop-off.p8',
        'dragon drop-off',
        'dragon-drop-off.p8',
        'mouse move cursor, click and drag dragons away from the plane\n❎ start a new game when the game ends',
        'dragons are attacking your plane. drag them away so you can drop off your cargo!',
        "◝○ネ◝oル⬅️はY-ン◝◝%を◝?ナ◝○░◝よら◝よ'ュLxれ◆■😐゜³を⁙るO³゛~\nニニか웃Hまみ&\"ニfE>$)◆「ン…さ<bさラ゜dラせ▮いョ◝✽#メュトれろあュにト、	ス◝<!&ラよ◆hろ◝]▮■!◝ミ!ᵇニ○/ヲ◝ᶠ⁸◝○▒◝◝◝/☉…◝{\"M□ュ◆ラヲ)⬅️ᶠナ○ひわ?A³⁙◝'エo■░よL★か&ん⧗f2\"5ュね●$る゜|アあDらる♪…1ュヌ9★,Y*F□る゜M`ノᶠン!へろよ(░よcハO&•◜シ2Rヲ◝³ラ◝'ヲ◝▶ュ◝◝◝○け…ユ░_Bる⁙◜⁸\r(スp░⁶⁘l8Bᵇ▮░●¹✽\000Ah「P⁸▮²JるXH0き$😐✽⁴³:⁸●ᶜ\n⁷▮⁴C⁶✽³⁸²ぬき0モaAaチれ🐱B³シ\\◝に♥き★0\"◝G□🅾️!░◝aPHaュ_■F(⌂h▮█✽こ\000✽\000,、う$😐⁵⁵、 a,(ナ@「●ᶜ\n⁷●。 ⬇️る▒a✽◀░qᶠ+⁸ネ゛6\000"
    ),
    -- end dragon-drop-off
        -- separator
    -- begin graphics-with-pico-8
    makeGame(
        '/carts/graphics-with-pico-8/graphics-with-pico-8.p8',
        'graphics with pico-8',
        'graphics-with-pico-8.p8',
        '⬅️,➡️ navigate slides',
        'build a graphics engine',
        "◝○ネ◝o、ᶠ0⁵Vワ◝◝◝◝◝E@★◝よ▮A😐ュエ	ᵉmあl◝タDコ#⬇️⁸◜せり4Fᶜ⁷◝れa²☉ュ_웃░=ゃ□ᶠ◝Gp<@▶◜o4♥Hrっ★ろ◜○+ゃ➡️ᶜyH●ョヤᵉ⁴9★ 98▮◝/,れっyコて◜wKrE$\nャよE∧8@1&ょ◝マ)⁸⁷ら░ュト◀*8★<➡️◝いュり7レよ\n8▮ Sン◝ヨ⁙る◝ウユ◀ゅ➡️ノ○⬆️ᶜ゜gヲよ%9A□🅾️@ン゜\rᶠん□eロよち$⁷!き	웃◝コaニ@&セそモっヨ○k⧗1Kᶠセ★⁴け◝;l0a⬅️ᶜラ◝;lょL&□を◝◆a「Xヲ◝◝◝◝◝ニ\000"
    ),
    -- end graphics-with-pico-8
        -- separator
    -- begin improve-remove-premove
    makeGame(
        '/carts/improve-remove-premove/improve-remove-premove.p8',
        'improve, remove, pre-move',
        'improve-remove-premove.p8',
        '⬅️,➡️ navigate the menu\n🅾️ select your move from the menu\n❎ get back to the main menu if you are in the pre-move sub-menu\n❎ skip chip movement animation\n❎ start a new game if the game has ended',
        'a game of strategy where being predictable will cost you',
        "◝○ネ◝oひs\n?1~fュ?ヲ◝▶ニ❎⁵チュ_Hヌ=□\\2◜/!ナネさニ○D⁸?p█◝‖ハにユ◝ネ'◜ん<ュ◝◝◝よ゜~ナ○Jヲ♥◝。゜ᶠ゜◝+JみYヲ゜1ユ•	◝•◀◜$ニ○ろエュ○「ワ²モろ◝リ▮ュᶠれ/ュれ◝✽$~eュ_Bらo4ュ○「ニ⁷おユ○ヌナほユ○ネ7◜せュら◝◝◝◝ヤヌ⁷◜せ░○ヲトヨヨユヨよけ⬆️い✽◝■³シ²゛★ヲトぬpFるE□◝#◜⁸'◝゜をイ?ニ❎ス/ロ?\r◝◝りゅ🐱▮ ⁘⁸ハ○B⁶a\000\r@れ◝█ᵉ⁵#@(」◜'ュ◝³◜◝よ\"░❎♥░♥◆□゛◜⁸◝かユ゜◝◝\000ュ◝	"
    ),
    -- end improve-remove-premove
        -- separator
    -- begin broke-out
    makeGame(
        '/carts/broke-out/broke-out.p8',
        'broke out',
        'broke-out.p8',
        '⬅️,➡️ move paddle\n❎ play again',
        'like breakout, but broken',
        "◝○ネ◝oル³L]モャ◝◝K000000000ユ0000000000◜◝?#`````````ナHᶜᶜᶜᶜᶜᶜᶜᶜᶜ\\⁴ᶜᶜᶜᶜᶜᶜᶜᶜ😐⬇️ラ◝⁷Bら◝゜「⁶⁶⁶⁶⁶⁶⁶⁶⁶◜◝◆\rᶜᶜᶜᶜᶜᶜᶜᶜ😐⬇️◝◝oノ◝?hららららららららら8(◝◝?▮²◜◝\000◝◝れ1000000000ᵉ◜◝よ➡️◝?➡️んらららら	⁶⁶⁶.²⁶⁶⁶をわららら8(◝○ ⁴ュ◝▒a```ナ⁴³³³◝◝◝◝ᶠエ‖◜◝¹ハ◝◝⁷Bヲ◝◝◝◝d░◝?\000ゅ◝う◆◝◝ウょ○"
    ),
    -- end broke-out
        -- separator
    -- begin minigame-mania
    makeGame(
        '/carts/minigame-mania/minigame-mania.p8',
        'minigame mania',
        'minigame-mania.p8',
        '⬅️⬆️⬇️➡️ move cursor / move chip\n❎ pick up / place chip\n🅾️ rotate chip that is currently picked up\n⬅️⬆️⬇️➡️ move\n❎ shoot (if applicable)\n🅾️ move onto next arcade cabinet',
        'repair arcade cabinets and then play them!',
        "◝○ネ◝oル…たネ◝◝◝gナ○ウわ◝◝◝◝♥⬆️Pる◝Y◜◝<こュよン◝◝F◜◝⁶8ら¹◜❎ュ◝○³◝◝◝◝Dヲ◝ᵇュ◝○³◝◝◝o➡️ン◝⁙ラ◝◝✽⬆️◝?ら◝◝◝◆ソ◝◝◝Oホそ✽□Jヲ゜ゃん?웃◝○り◝⌂◝◝o⁷"
    ),
    -- end minigame-mania
        -- separator
    -- begin drifting-keep
    makeGame(
        '/carts/drifting-keep/drifting-keep.p8',
        'drifting keep',
        'drifting-keep.p8',
        '⬅️,➡️ make the dragon flap its wings\n❎ restart (if the keep falls down)',
        'the castle keep is drifting in the wind. stop it from falling down',
        "◝○ネ◝oルヌのYわ◝◝◝◝゜◆E◜フま²ラ?イl」@ ◝エなMᵇCマ/➡️ハシ%$9B0ュ7ナ?2l	ᶠ²◜て⬇️よ&█★\000Aヒせ$¥ュe░|⁵ナOカ░よfウa✽_りしcP😐-ニA▮nを「c😐か🐱\000▤ッ_ᶠBヲ▒◝•\nᵉpリにュ3I゛⁴チ😐◝■🐱\000▤ヲ_ᶠBまントくナ\000/◝め$y▮ᶜ゜◝よ…¹る◝:さ█❎◝゜ス³うュ'ネヒi\"N²\\2みみヲQ🐱⁷ヲ▒◝[ヘ█◝3ス⁷ろょ◝░◝!◝◝◝よて◝◝B◜◝よキ◜◝◝#◆◝◝\000◜◝²ニ◝Oヘ◝_⁸る◝゜ 🐱◝?▮◜◝○る◜◝8"
    ),
    -- end drifting-keep
        -- separator
    -- begin beat-bot
    makeGame(
        '/carts/beat-bot/beat-bot.p8',
        'beat bot',
        'beat-bot.p8',
        '⬅️⬆️⬇️➡️ move\np pause',
        'the robot only responds to commands when they are in time with the music',
        "◝○ネ◝oル•⁴+ハ_ヲ-ヨ░◝G☉ョ◝⁷+◝ャヘり◝ョね³◝◝?…ノ◝O${ままxヲ웃⬅️'ュよるれんれ◝◝◝Cラᶠよ░♥かまxる/ニ❎ユᵇ◝◝◝○ゃんれOュ¥おpヨKxX゛Iュ◝▒%◜◝Eヲ◝ᶠュ◝⁵░◝○らヲ◝⁷¹◝E゛>..゛>おpヨᵇWまヲˇ◝◝◝♥ノ_..◜ハ◝りん⁙゛◜◝◝゜➡️⬅️○みヲ%<ニヌ	Oxヲxる/ュ◝◝?\"◝○れ✽か	◝❎ ⁴⁸	A8●◝ᶠ@▮░qラ?²ヤ¹◀ᵉ◜G(ら	\000x²◜/ュ◝○#"
    ),
    -- end beat-bot
        -- separator
    -- begin root-loops
    makeGame(
        '/carts/root-loops/root-loops.p8',
        'root loops',
        'root-loops.p8',
        '❎ classify graph as a tree\n🅾️ classify graph as cyclic',
        'is it a tree or is it cyclic?',
        "◝○ネ◝oル✽り⬅️へ□◝◝エニI⁸◝◆gナ❎cろaニ◝!ネᶠᵇxム○れ◝!■◜◝⧗●◆ユ■>るGxネナ웃、M☉、M☉、M☉、M☉うめ2}゛🅾️+!、WB8な░p\\	ニj🅾️▮ᶠトhらh こ▒😐⁶rセハュ◝³のム:(ᶠハく<⬆️/‖らq▒⁙うナ⁴◝◝Iテ~フホ+|✽にユsなフ◝◝フ⁸_お◜_kん■9あ▮9あ▮9あ▮9あ▮9よれd、WB8な░p\\	ニま□るコ4⁴6¥っh こ▒😐⁶\\🅾️ょ◜◝█,ょAy(ᶠハく|i³ス⁵Np🐱⁙ュ◝し゛いS○とろWヲ!ょ◝◝/fy	゜ニ◝S;🅾️っカ░っカ░っカ░っカ░っン。&ネま□るq%░ネJ⁸んˇ▮なす!ぬカ█カ@F³F³.んe◝○@∧ハき<⬆️♥ラPゆひ¹ム²'8り	◜◝R◆イたo%Ny+ヨC∧◝◝_アラ□~$ュZ;🅾️っカ░っカ░っカ░っカ░っン。&ネま□るq%░ネJ⁸んˇ▮なす!`4ぬカ@F³」\rノrュg◝O▥=4rP゛ゅCンキ⁶う█]ナ⁴'ヲ◝OッロhえラVヌ⬆️トはュ◝◝、ニょラ□◜?ふネ☉、M☉、M☉、M☉ュン。&ネま□るq%░ネJ⁸◝5\r▒♪⁶😐⁶😐⁶ラかネの◝? ょrP゛ゅCン1m\000めら	Nユ◝◝ノ◝ト³"
    ),
    -- end root-loops
                -- separator
    -- begin klein-bottle-tweet
    makeGame(
        '/carts/klein-bottle-tweet/klein-bottle-tweet.p8',
        'klein bottle tweet',
        'klein-bottle-tweet.p8',
        '',
        'xxxx',
        "◝○ネ◝o,ヲ◝◝◝◝◝ほ😐▮ユ◝&A0ュD🐱▮~゛゛ᶜまXAH\000◜$⁴@0$\000▮░ᶜ\r?🐱ᵉPヲ⁙れ○⁴!!⁷\000`▮□v\000ュ웃p▒、 ⁴⁴り▮█ト\nᶠ⁸⁶⬆️\r	シユ?\000ᵇ³@(_ヲ○░\r%\000」⁶⁴ュる/¹⁶⁸」を■²◜A⁸よ…p!⁘、ニ゜⁴うaA8゛ `ナ'゛テる³F⬇️ニん\000😐キ🐱A¹●… ュV▮お\000😐▒+,ュっヘ³⁴⁷らH⁸。ユ#\n(%ナ¹A「◝ᵉ⁸hHa゜ら「ヲ⁙░★²ᶜa!ノ¹~ヒ⁷🅾️ニ²@●◝ク³\000H!░◝。8る█ ⁸◝ほオ³ !¹◝め█せき▮ユよC8²オニ◝x█ ░ᶜ◝シ  @ヲか゛ ░✽◝m8█ユよを…ユよᶠᵇ◝◝◝◝に	",
        true
    ),
    -- end klein-bottle-tweet
                        -- separator
    -- begin fetch-quest
    makeGame(
        '/carts/fetch-quest/fetch-quest.p8',
        'fetch quest',
        'fetch-quest.p8',
        '⬅️⬆️⬇️➡️ move\n❎ jump / restart on game over',
        'who let the dogs in outer space?',
        "◝○ネ◝oル2まjる◝◝エ8@ホ█⬇️r■~゛テ¹○✽ユ◝ヤヲ?$◜ˇ⧗?□◝○4ュ◝ゃユ◝ほる◝゜	○♥◝◝◝よ	◝◝ト¥◜◝?;ュトれ◝★q⁷ュ◝³を◝j∧4Aノe웃◝ˇ=ニ\n+\000◝かZこ¥ニナネ○さめ◀ユsヌ○\000🅾️DンC◜ナト░をqさBヲY~68v$░◝¹◝♥8.◜フたユ◝ᵇ◝◝よ」◜◝./◝めユ○\r◝はユ◝◝◝キニ◝◝o<ニ◝゜0◜Lュかる◝よ@$ュ◝⬇️ユ◝◝\rュi◝◝◝/⁴"
    ),
    -- end fetch-quest
                                -- separator
    -- begin the-titan
    makeGame(
        '/carts/the-titan/the-titan.p8',
        'the titan',
        'the-titan.p8',
        '❎ select choice\n⬆️,⬇️ change choice\np pause. can restart the game',
        'choose your truth',
        "◝○ネ◝_ル⁷☉け゛‖タよ◝○Ehヲ',,ュ🅾️%🅾️✽'T\"く<ニ\rᵇせD□●!、ニえヲ✽■★x2コア、⁴<ᵇ	\r•□\"ヲZ■ろ!◆!ゃる('HGおミ➡️n ➡️ニ²ね/❎ᶠ⁙▮キれFP,゜s$んうOヲᶜ¹_fな…H□、サ+<ゆセ◀a$るさ∧QJヒ♥#B、`…☉ネオ\\tみ゛★░<•o🐱レユxひ゛♥H★んほ!웃'ヨ4ゃ!Iい8\0002ᶠヒラx🅾️e	{◀■)ヌ▤ネ⁸d♥⁘た}G★スえ6$-ˇ⁶bユX)ふに¹O★チシ◀ᵇWネ9*ンさK∧ヤ}ヤ;んあ⁴♥れ\\aDrもセc!?ろq7E◀qくエ5hノラ➡️。Cか、■i.;むアウvャのろ*~ᵇむャラ★6b。ン8な]✽キ|⁙lB4G★▤ナ;6ウ゛iaᶠろql ➡️ᵇaん⁴■んは,け~お⬇️wエヨ4エr$u、!セ1⁘た、◆<ニユGメみ\\おkたうて웃ゃニ/なネhᶠエヨp\\$IちD=んね⁘ュuDB<かミ8ソへ⬆️l■q6□」Zま🅾️リヲxひRシq\\リゆヒえよへdイ゛9⧗さ|Tワハま\\▤Dh∧リユ。セは]4w&つチMウKウむ░こ웃っ、>ャ6タ\"pxなcm☉、ヨまをく웃;❎/シく\\r…ネ ▶ねみ∧ミ★+あヒIユ。エク~トX<キ⁷<9⧗nッ G.Oをネ\"か@ュユルミs|イ⧗ミ█をホxっ,□ᵉね4🐱M◀ニる²sx、9'➡️g\"h□B\"なA$³を∧せr…k●すセQシyhおぬ,➡️cりᶠMD、I◀Q_な、;/ね░?rっマj%ラVx🅾️。=ケキ▮ほY🅾️モ;&ヒ…イ◀●ハけ♥░DF$=ナhは8\"aWミタaイz…ろ∧⁸のoホム█qx🅾️u웃$Lユメム❎K5‖,」qてセdIろカ9<Yeコgねmュˇ゛ル<]1Lめ+⁴む\\⁙b★んs8⁴L•⁸❎ れ<ソ░\\♥も、Cヌ⧗>L★らr<シレ、<…3ラわuとみ🅾️▮ト▥|ヨ░zなミむむ$❎.\r\"Oク³⁙う³メラク♥ネょSか゛つら、u▤ミタさfI⁸Bろ⧗%웃せs「❎dv-2あtIFルのぬふM★⌂➡️5m=$ゃろW}エク!_ロ⬅️ケq、LうなセeょRメコ■bたス🅾️セqxラ⁴I8⁶😐ヘˇ'%8ンv4るRGᶠMゅˇ<❎D●G□?,エqMめヨ、;=ヘ■#9'I😐■GBメ8DムxヌAr9▥H🐱 ■ラD$웃ハゃ❎4ラ}ンぬょQ★れ◀、おれXᵉト6r、🅾️G□$\\🅾️#ねH゛♥★ネ8Zな)せ\\I。E🅾️⁵のっヌ▮リwfz@れU■■8★ネXくOつfスQjエリY□ゃ/8へ#ね「<'おHT⁴や😐😐シS、セg_y゜ョキn|;るっR|RcみGr^♥pそ³つXrq=9ッt1へ、イ*▥ˇD□░H◆ねx❎(かょカ^いメ☉さセ、お6\ri⧗●$ョ⁴あさBt◆ミ」、キまキヨ。ア-■❎dラ!⧗\\\rH★た●さ;ᵉ~kあを■hッpfんqd➡️lGラ■の<そ#んセYリるみCメH}おフセカxbq☉fホ゛Rるう■sふイˇ/?⬆️oエrゃ _<ん⁙ᵇへめ➡️み\"さ9せ1▒▮◆5▥゛ZタbK☉#ヨJl9。f⁵ᵉ1웃い◆ら8ナ❎%L¥□H、▒\\⬇️りン]イねつ▒$yなハHrフY%んq…ネ9をnネMろめヤp$□めw8★nむ%zxヌ:にモRち{ノほ'ょほ9たmノk🅾️。\r♥ム⬅️D4ねハヨmゃcけzムはう▒さ➡️'゛GたひCヲく\"!?ろめリ;へ゛え#9🅾️モねまヌ…QHxrナH`	●ムJナかナセˇ゛xRい➡️+3~▮C★♥+fシヨノンけ゜さ‖エ■∧o¹_▮r、sオつ⬆️ちヘお$░ヤ5,➡️░&ら⧗█ウRセ、n➡️9iヒᵉ?♥゜\000"
    ),
    -- end the-titan
                                        -- separator
    -- begin picade-simulator
    makeGame(
        '/carts/picade-simulator/picade-simulator.p8',
        'picade simulator',
        'picade-simulator.p8',
        '⬆️,⬇️ move selection up and down\n❎ choose game\np pause menu. when playing a game use "back to picade" option to get back to main menu',
        'play all your favorite pico-8 games in one place!',
        "◝○ネ◝oルせクへ▮⁷ア'おZにlミヨ<シ◝1iラ]ホ\\g{>んUヤハと;テ8xミ♥ょ[ほ。ヤ、nGx;トqyヒ∧ネNるな⧗ハ;⧗Oツもルヘ⧗ネ&ゃネ⌂]f[<;)}ら゜タC⌂、>シSyBᵉル…W⧗シ‖Bり(ᵇノか、よD.ユ✽✽⬇️カ\\ワカ+うq⁶<🐱⬇️ᶠ⁸xな<wなチけ➡️?@…W□rまュ█゜っ!)9~\000エ゜ぬさY{フ∧ミ🅾️゜ら。?うyておネ⁷4によの゛うナやむル;○ナ⁷ぬねやqめよみ4っラ。ゃリy|!る#GᵉゃZもラょゃiようにえよチ▥_@~qケヨ³ゆ=ˇHわう6,,,,,,、br゛エu>み#aフほモ➡️ひ★、■●…ミまワれ゜ホCヒ◆.}▥}?ᶜねす🅾️モハᵉLノむ~ぬんクヒ9ャ⁸ゃAラ⬅️⁴░ᵉ	▥れフ😐、ラ⁴z░ᶜᵇᵇᵇ#uっ19ユk▤。⬅️░M2ほ、かオeるニ~ヌ❎エお░lくイ★GなD█z○h★♥つく웃JᵉI<ᵇょ/おョぬアᶠュぬルLr」BIb!I:$,、W'ワ/;⁴r•O4🅾️゜#セヘ$qよ2めヌ◆'ナ²\rᵇ=゛○ュユ♥\\ゅ?ょᶠ6ナ❎ニ;かリ=○xチこ⧗Cp8◜^xマyゃ゜ネウ゛ノS9ハ	9らみpら◜ゅニ	∧そl⁸ᶠ」ᵉ{るC\\ヌ◆▮ン;,<y◜\000エE:ッムx,,,,dヲ$n웃み³웃⁷_よ★⁴りU웃✽S\"☉;•‖z$#つ\r▒³★ろるくヨ⬇️、ニ★|	❎レ█Lお⁸	Ybくろᶠ▥,メ%\\ゃ\\■★ぬ0ᵉ◀◀*ュ\";Lᵉ「ヌおネ「◀◀◀◀◀ゆ8うゃ/;◀オ\\ョ□ん‖➡️d	!$ヨルゅᵉIアF$qっヨチゃᶠR]▶92ᵇ_8p^s%GC|けんねR★!9😐ケ「HXまDテ_ま%4ぬ7ほオaaaaaaニ⬅️エワょえZ○웃゜ぬスrd¥⁘▮★Xまbエ]よルち゜ラ⬇️#ミア*➡️☉$ タbニA◜pうニヲ!ュ🐱イrノH❎$aIのねp、ワ゜K∧ミuュ0ホ🅾️c■★らd□¥ゅるるカ゜6K○ナᶠ³□★っぬぬぬぬぬぬオcワ}ソヨょ/◝ᶜ[,タハ○⁶|ゆ▤_NニJケW_ュ1ov~○ユGョ■_もん□マユ⬇️ツょ8ラG¥あ⁴ゃョdニくやトヒJC¹+Gけ4ほユ_ロス⁙KZ¹³あち`*░しfュヌy○9フhb9\"とケ▥ヲ⁸ゃ	゜の'んくょノい⁸「ま@ョラ|<フᶠ]ゃロなょシ#m2カa🅾️うIおナ…も、ほ<ゃq◜p_⬅️\\,Kゃpハ\rはュ2▥▮○ムツᶠKロれ‖ルe▥'qみ。ュユれ,■ゃラ⁷♪テゆメZz。r<、Gへe⬇️5y$Nは&ヨて%=ハ▤゛カ゛=pヘこゃく²	;|ゃ'◜hVんᶠシ,¥j➡️…ケᶠを∧Gけゃえぬゅᶠせ▥。k◝…。V#/❎#ンAmょ■ょlMrノはgンしW∧エ゛8tへQ█eリ%YネXヲムは#るモ▥,w,★Mホ⧗ン⬅️□Nな⬆️cエふユ-、ナ❎lょr'っ➡️?゛q6◆;、ゃ\"゜'ニさニ゜れx2?█ラG\000░3Iノ	Gh8ヲ'ュᵇ"
    ),
    -- end picade-simulator
                                                -- separator
    -- begin countdown-to-meltdown
    makeGame(
        '/carts/countdown-to-meltdown/countdown-to-meltdown.p8',
        'countdown to meltdown',
        'countdown-to-meltdown.p8',
        '⬅️⬆️⬇️➡️ move cursor. hovered atoms become stable',
        'stablize the reactor before it causes a meltdown!',
        "◝○ネ◝oル³Eネミュ◝◝◝とユ◝◝⁷🐱●░🐱「⁶◜/Iれ$`⧗☉ᶜ😐◝	!웃ゃカd◜♥I▮🅾️ケ□▮.◜7ラ◝?H★んるE⁸ニ◝Bノ\"ニ、を◝\"⧗✽●3ュトd⬅️⬆️⁴| ナ○…	▤!🐱-IBYeン゜d	2웃ᶜトへeねセT6ュ▥X⁴➡️□R G⧗웃ョl♥ニ0くI…ア2,B◜ᶠVン?'X@⁸く	□あ…✽ぬユSfIB♥!1★▮6」…ろ?ラ;bく3ネよe★ら@らB:,さ0ユKはHの4Y∧,M∧ゃ²j	hx❎ᶜ.I□Aオ$🐱…0F★✽ヨ⬇️ュせハ♥ろのね░゜□$5ᵇ,5ᵇ,DBメきュる!◝oᵇ*]\"D⧗メMうニᶜ$4░\\ょHナぬわ⧗`W8れ🐱LンHてロ░しあ8れ³★H◀ᶜ★わラ、;v⁸sナᵇgH♪3ケ¹eqっC2ツ★░🐱░&웃|`웃⁴fロ▮1ム{あfl2ᶠヨpア∧⧗゜ひ⌂つmsu+ラセえz4➡️B□&➡️░I$aMハへ;わ⧗ろ◝SCっ+ゃ□+クf{⁙,4ヨ◆daぬ、,#ホを⁙⁸★□~ネかセ゛¥PDる○I▮0 	•ヲ2\rᵇ○の█m!	⁶★(⬅️ナシわ░ニ웃%」Xe6いっヲは▮りa?スカ♪◝♥DぬUるE2K…ユほうュエc░✽d#\r, ░ユャ∧\000Yd⁸ これヲ゜$ンら◝7…⁴(,30▮ユ○ `I★⁴⧗⁵Lを◝#Iユろ★ᶜょ\"ᶜ2◜'■、r5웃█◝WヒX$4A\"8ヲト⁸◜◝はミ◝➡️れ-◝ヨ◝…◝◝○ヒ◝り◝⁴"
    ),
    -- end countdown-to-meltdown
                                                        -- separator
    -- begin skyline-tweet
    makeGame(
        '/carts/skyline-tweet/skyline-tweet.p8',
        'skyline tweet',
        'skyline-tweet.p8',
        '',
        'tweet cart that generates scrolling city skyline',
        "◝○ネ◝olり◝◝◝゜▒⬅️いユ○ネ?り◝○☉ュ◝ᵇ◜◝⁴◝C◜ノ◝_ユ◝'る◝○\000◝○!░◝よ0ュ◝✽ニ◝?▮◜wュ◝•~「◜に`ニ◝o░█◝mヲ🐱ユよネ\nヲヲ゜ラ✽'ュにᶠP◜ト!ナ○ゅᶠ░█ヨ◝⁷ヲ◝³ $ュoᵇ/◝⁷るわᶠニノ◝◝³0ナ○²~⁶◝◝\"ュアょOAX▮pヨ[ヲ」⁷まン✽/ュ◝/⁘ᶜgヲか♥こ0◜Wニ。◜\rんユ▶ヲ+😐◝WPヲ_░トI█ユ○ᵉ?●ヨ○ᶜOニ◝\n◀ゆユ[ヲ7⁸る‖◜に$ら…ユよハ.4ュᶠれ◝か\nる◝0ュ◝⬇️…ナ¹░'ュト「「\r◝🐱◝¹ヲ◝⁷aナᶜよ░░◝Wヲ_⁶ aニシ…ユ○!Cり◝5,ュ_るかCン▶ュ。NユkHヲ;⁴チニかユ░ᵇ",
        true
    ),
    -- end skyline-tweet
                                                                -- separator
    -- begin prime-time
    makeGame(
        '/carts/prime-time/prime-time.p8',
        'prime time',
        'prime-time.p8',
        '❎ shoot\n⬅️⬆️⬇️➡️ move',
        'navigate through the quantum realm and factor numbers!',
        "◝○ネ◝oル⬅️⁴⁘つャ◝゜ᶠユ◀◜ᶠニ▶をイ◝⬆️◝?!◝ᶠᵇ◝ᵇン_Xントこ█◝ほL、!◜ほ░のHFᵉ◜Wᵇy▮セBる#◝か⁵⁵%\"HヌJラ?■A⁴⁶K4rラ◝き¹ᵇ⁷ヲトa▮◀F♥❎◝れ⁷P█░ユ³◝³ 「⁴れわᵇ~.とハxル▤aたねろふ█_➡️^Iか~3`⁸&9⁶ナOなˇ#⁸8xノナOP🅾️0█♥🐱<らoᶠ<のh●-\"チd\000◜#웃\000⁸んく9の⁶■a⁷ヲ	⁸ニ…⬇️$▮🅾️\000くュ✽\0001$●き⁴◀p⬇️よ²Br、²v\000⬆️\r▶る?✽ᵉる7⁸o「ら?⁸\n⁷ᵇcき⁘!ュ<<C³□░⁵さぬユ゜ᶠ	@ᵉ▮う\000□ᶜよ░こ 「ナ\000るC\n🐱ユ⁙X⁸ᵇ⁸●、`³ᶜ	るo@\000v\000!ナ\n!😐゜り?れ/Cり/⁷H¹\000░●#⁸●▮◜\n!³6$さ\000ᶠぬaニほく⁵⁵³░g(ᶠ○⁵aヲ\000🐱B³🅾️0る゜、\000		hっ▮ぬ… ュF\0000\000⁵⁴「0█ユO¹	)\\t0$⁴ュ」◀ゅ⁸a³\n□⁴れO、ナニ⁸/ᵇヲ74「□ᵉるSっ \000よ¹😐ぬく¹ニ⁸!$ュV8BBX¹{█➡️ニワa\\れっ▮゛◜⁵¹\rり³,ノ\000Bヲ7らp░★a⬇️ᵇユ7▮F@Aっ▮ᶜヲや█⬇️✽⁘BH\000◜ᶠ⬇️a⬆️#t▮ユ?		ニ	@B♥◝\r¹8@1(ュか⁸っ¹▮ゅ★4ュ_p⁸る0きqス□ュ○2⁷	\000¥D⁘◜_■ナKLイbI◜ほヌ\"I░◝○█▮◜ん⬇️Rヲ○ᵇDB□◝フ…@★ヲ゜は⁶ᵇ◝◝⁶"
    ),
    -- end prime-time
                                                                        -- separator
    -- begin shark-shoot
    makeGame(
        '/carts/shark-shoot/shark-shoot.p8',
        'shark shoot',
        'shark-shoot.p8',
        '⬅️,➡️ move the plant back and forth\n❎ chomp the bugs / start a new game when the time runs out',
        'lure unsuspecting bugs to their demise',
        "◝○ネ◝oル😐は!そん◝◝◝ヒヌ(ュ○	トユ?ハナ`ュ?ᶠP¥█◝!¹\n⁷◝W⁘を8ヲ゜ラ◝◝◝◝&#⬅️ュト◆$░○… ◝#⁸◜\n⁷◝゜テ웃😐、ナ◝ᵇ.ユ◝゜ヲよ5ヌᵇ?Mdノ○ぬ$8□g%웃█ナ◝\"かTお%&◝つア▒$ノはNュ◆ムj6'Mロ○ヌノO◜'ュゆ-ノ◝る◝`▥◝yヲ゜♥⧗◝よ$ハ○や$\"⁷◝&◜▶キLヲトユタDeニ○\rる_ッ◝キc웃てょ◝も□$ニ○□◜コ'ュ?xれ○もᵉュ/HXヌW♥ろヤん⧗#⁶ゆケ゜ᵉ|웃◝⁸ˇsWラ³•B⁸•>ウ|*ら³>…aᶜ⁸◝ケ★ムむ▮<!<ア◀🅾️▮~ニ!、Aま8)ᵇ○🐱か●3(😐?Aる◝◝◝◝S¹"
    ),
    -- end shark-shoot
                                                                                -- separator
    -- begin terrain-generator
    makeGame(
        '/carts/terrain-generator/terrain-generator.p8',
        'terrain generator',
        'terrain-generator.p8',
        '❎ regenerate terrain',
        'generate terrain using perlin noise',
        "◝○ネ◝o、_ᶜうや5アEHろ░d\"•ろP➡️!て➡️`aニ	⬇️Lス⁙ᵉ9ᵉ&🐱H◆$🐱゜▤、…ᵇ<■⁙A★⁵😐Q🐱ろ□ᵉJPニたp$&□'🐱⁴░>□イ*░▮□░ゅ……☉`▤らB&G&ゆ▮◀み.░\000a、ニ98゛くは⁴▒⁴2 れ\nᵉI□□ラ☉、\"4🐱6🅾️ 「a	#D▮ょ ⁸へオ⁴░'r%🅾️\000¹OB➡️▮,웃J\"カDナ	█0H▮RB²Ib\000たナHRWノ▤X²!くCス⁵▮∧ぬろタ@るPセBiろ'b□た⁸る♥▮,るの░H\"@「おアはスへtこ⁴³◀2⬅️Dさ!d!dCB🐱▮\"HQG…²$\\ニ⁸⁙▥■░✽☉D⧗ム⁸🐱ユ1\"f⁴lりˇ$⁴」\"▮ 、웃⧗☉⁸」…`る,¹⁸Y□⁸$ニbB2タ ᵉ\"	■もラチKH🐱\000➡️⁴…つD*░HeあH²bOらろ¹おゃむD▤L⁶」¥ゃ⁶😐gね¹ᶜG\"kXh▤(DP9\n▥hh⧗さ8\"ナ☉T◀i⁴9★+2★@░D\"エ6dHB>⁸1□V\000s⁸LRあ(M⬅️⁸$➡️▮く(●⁸0★⁸M。⬅️8H,qうA'を ⁷$ニ⁸さナ➡️ソsわス、➡️$\000³1|2	c░'⁴`<のE`!て★L q-,A²L2゛&웃D2q \\★D★⬆️⁴$ゃ9BD…□ハ$¹➡️ナ!ろ⁴ユhᵉ★ □ぬ0	ニチ★、웃\000➡️さ웃⁸3ゃ░…、セ,りるE⁸	ノᵉ⁷ᵇゅ<りI░(▤░ユr`…\000お✽\r⧗Lᶜ!%っᶠ⬆️'`\\⁷っ⁴¹☉#♪░◆웃スb!⬇️\000░゜お\000🐱っ‖」∧ ˇF★0■1 b	\"■□🅾️ ★0➡️A▥ぬnd⁴(●■zX⁙▒xのひ◆⁸KFFBᵉB■をれんA゛I∧★アBハ1…☉H⁙G⬇️ニB★gEHi░て■2■ラ░#カ□❎lり█V$、ᵇ●rp1█ぬ Lv☉▮F⁵█0み■□Fあぬ%▮ぬC◀➡️♪<😐&a웃]♥■ナIlIあむdIな,$⬅️り🐱☉.162ぬ⁶,3ゃr⬆️DB6	<れ⁷■ゃろ#セ□■³r☉Eh\"⬇️\000、	\rあ░…、⁸\r¥Bそ⁘M$➡️q-ᶜ⁙Y\"♪ヲDけ웃I∧っ⁸…⬅️\000□ゅ🐱⁸□セ⁸ウ▮1I∧³セ□C◀KLス#G0\"‖!イ⁘▥$I🐱X³¥\\えス!Dけ&□!_ K😐さY 	I|ニ⁸⁙‖🅾️09□9F⁸ツ⁴ん★,t■□¹&G▮$`オ !てDハ¹ᶠ;⁴➡️o!\r⌂웃⬇️⬇️ca$☉@ !ᶠ★⁴□bろ&」ᶜ8▮□RI□	「F★░ホ□_⁸ま●⁵⁷░⁴[キぬ웃p0Nな¹!⬇️$ぬ,➡️NFᶜ³♥$「.ᵉBムきb	く<a웃⁘◜!▶■░'IA²■J「ᶠ",
        true
    ),
    -- end terrain-generator
                                                                                        -- separator
    -- begin picoquarium
    makeGame(
        '/carts/picoquarium/picoquarium.p8',
        'picoquarium',
        'picoquarium.p8',
        '',
        'inspired by the command line program asciiquarium',
        "◝○ネ◝oル⁷スW?	アね◝◝◝シ\rIュに⁙」,ュヤ」◝リろ◝゜⁸!らる◝よN$$ュに¹\000⁸◝_n◜♥▥░p'★Hマ○は\000ス\000\000█らを◝かtナ◝⧗んエ\rさ□□□□□□□のヨ◝゜ヲか$□□□□□□□◜゜•?\n\000らを◝○ょュよ□◝&★IHHHHHHHHヒトア◝⌂○▒LBBBBBBBるト🐱◝✽\000っア◝◝K$っ!!!!a웃░ノユ?H$っ$$$$▮\000ᶜ◝゜◜◝ひ+!うS				◝○0ヨル⁙イホエも~5、+□YンqハWy⁘ᶠよラ○	◝ミˇノへL🅾️9ヲsᵉ◝○.リ●d~エュ❎ンら2よg~ひ░ユ◝ニ◝○め⁙るねヨ◝トるよ웃せ◆hᵉ?*~5、\n웃(~ノg゛れれ◝<ュ/す◜\\IX&G⬆️◝?▤ッ-リ●d◜⁷▥ト2゜Xヒw◜⬆️░ユ◝?7◜◝◝タ□□□□□□□□□□□□□□□る◝ト\000"
    ),
    -- end picoquarium
                                                                                                -- separator
    -- begin slylighter
    makeGame(
        '/carts/slylighter/slylighter.p8',
        'slylighter',
        'slylighter.p8',
        '⬅️⬆️⬇️➡️ move to a different house\n❎ toggle the currently selected house\n🅾️ skip animation at the beginning\np pause menu to access other difficulties',
        'help the star get back home by turning off the lights',
        "◝○ネ◝oル♥ぬJoえ%∧◝◝◝◝◝か⁵8*r█こ\"⁷ヲめB*キ☉\nたH#*$ラ?っ\"Hオオ4🐱⁴Gh★○イのアdろクZろり□\"∧ハ⁷シ/ホq、ノq$メわねCj◝/ん/ュ➡️エ◝らˇ\\J(ゃし░★ユ+ヲ⁵ュ²◜⁷ロmuノヨ✽#ュᶠ\"!⬅️😐レ▮∧ac&A◜ˇ⬇️pTけ□🅾️IᵉンシンセはKて2めラウ*?フ▤aM‖Sウg■$⁷テ◝▒もュ❎ンかっほおユ⁷ニ○い⁸ᶠG⁸○リホ◝ツpケノH>R	⁷ニフ.m*B□웃p✽PFン?ノそ ⁷モ▮エる³゛~‖ˇ☉[F☉フユをyゃ!○フ8{カフ➡️D\rお\n0ᶜ◝#}、かフヌ○C□ハっニゃホ\n◝³ユ⬇️}ロ?⧗#Xヌ\000Oヒ■ュ゛ᵇe😐ね$웃Lをエ、░³、 )9Bᵉ◜コO/んˇつᵇねよS웃「Vリ!	れ…³•ᵉり◆▒やラれ⁵d<ニO⁷'むロら、う▤|「◜⁷ュ)⁸◝•ᵇ♥^ロむ◝W□ソFᵉ	♪G∧¥~エ6,ゃ\"➡️□JあD\"よゅれrナ\nOx@⧗フ_んニヌ⧗□웃゛◀ウモ☉かこ●\\カLf●ᵉhv◜ᶠ、❎オG◜にた%ゅ➡️yるi?タえんれわ⁵◜O」▥'ュ◝◝◝⁸"
    ),
    -- end slylighter
                                                                                                        -- separator
    -- begin timey-wimey-stuff
    makeGame(
        '/carts/timey-wimey-stuff/timey-wimey-stuff.p8',
        'timey wimey stuff',
        'timey-wimey-stuff.p8',
        '⬅️⬆️⬇️➡️ move\n❎ jump, acknowledge text',
        'guide yourself through space and time!',
        "◝○ネ◝oル◆\"0🅾️~⁘Oョ◝+ニ	Oxる⁙おユ░'ュ◝ˇユ░'<ニ	Oxる⁙゛っ!◝[ᵉ!◝◝◝❎ンか+◜◝る、ᶠ★ン○³ナ\n◝タ	|ラよツ!ノノ○、ユ◝⁷のXヌ◝/ムHあヲ_っわMクキい◝yヌ◝に░トCる゜웃░░⬅️よ♪\\なpヨrっ◝H◜◝✽⬇️ュ◝♥ひ○&◜oュゃ◝かっュ◝ˇユ◝'ノ○%ネO◜◝○+ヨ[ヲWユOヒほユはュに2◝ヒャユよᵇ○セ◝➡️よの<ュGラ▤うュ‖□~ᶠ◝○!ュ◝かアgxメ○を9フ⬅️◝mヒ²ら◝;d⁶◝sのCっヤrヨ'\rヲ_⁘◜ウb웃◝よぬ#ントスOれ▒ひムハ゜{ヲ)ュ★ン○●◝よ□□□おユ◝ノ゜◜◝⬅️;⬆️PB	%ュᶜ?8゛i☉#IB、I□ヌH★▮M★よ2	░ゅᶠハ♥  ⁸⁸²🐱\000ニJュナ☉<ニ	Oxる◆ニ!░□J(く⁴ニシ░!ᶠ…⁷っ³ノ¹ゆユ░'☉「●a「●a「.◜ゅサ、おユ░'<ニニ◝◝'□Oxる⁙おユ░'<¹"
    ),
    -- end timey-wimey-stuff
                                                                                                                -- separator
    -- begin campfire-simulator
    makeGame(
        '/carts/campfire-simulator/campfire-simulator.p8',
        'campfire simulator',
        'campfire-simulator.p8',
        '⬅️⬆️⬇️➡️ move stick\n❎ get a fresh marshmallow\n🅾️ drop marshmallow',
        'enjoy toasting a marshmallow from the comfort of your home',
        "◝○ネ◝oル♥ま⁷わひけホ◝◝■◜⁸gヲ◝SAx🐱p●7ュ゜れ◝*ュ○⬇️ユ&あヲ2◝れろ_サユ?エュ゜□よ●'ュOれO◀~Nュ。゛Iヲ?%◜$웃+ュいヲ#ュ\"ヲ!ヨ●◝♥<ュO□○efᶠXら⧗ン○ゃ‖Jるか▥○れ➡️ヲ3ュ⁘◜\000-ュ_Cy⁸Byり❎9⁴?ユ▒オニHさD⁙ᵇネ▶ユHx●%¥	wヌゃろBヲ●+|⁘▥#udn░✽⁴Cれᶠニソヨ ネき✽▶、a)웃⁴アuDᵉN~「゛p□★Lにヤホˇ$Cれ」ユ#ョノs}⬆️✽◝x🐱オpV⬆️ネ	¹Gまン⁸ᵇ⁷Gハ<にpのぬ…ユ✽✽♥ノむbヌz⁸h8る_ナ#;こaᵇ	。モ…ユ✽p⬆️⧗$ニ# れ=ナ⁵んっロ、3➡️、★	よヨ%Fるaゃu」む!■~゜█ヤ8$♥=ᵉホ%ᶠんqナに█c8るネAwノ➡️つうヒC◜O▥¥b…ミニ	ᵉ♥ント」⁶まッ リ?ノっ⁙fM\"ノ○⬆️み6マス\rラQ◝⬅️アイくあ\\¹웃スおュOはたk✽ろノ◝*ᶠ²b◝め。、OロhT⁵ムトTャヌネホ!⧗g;zメっ◝⁴ュtd웃わ,ょ◝nこヘIお,2◝ほyEあんしうネヘユ○0🐱…セy$お⁸fヲ゜HrCッa☉&「★[\\◝▶6ᵇ🅾️Lら@6◜▶¹おフロ8へ1ᶜ゛♥fキ◜/⁴た0イき`みレまoヨw゛웃ヘニqノyろ!e⌂L□ョ゜てᵉイ➡️E$$Yキ▮a,ヘるエス⁸⁵@さッ🐱かIH●X□おdる8⁶ュ?お,xワ,@⁙ム○■🐱YL●V\"`ナ◝!ˇ#h▮ねゃへ,ュ◆ノ■ᶜ⁵L★ヲト$゛●ぬ▒\000◀◜/ラ◝ほ¹"
    ),
    -- end campfire-simulator
                                                                                                                        -- separator
    -- begin hamster-slam
    makeGame(
        '/carts/hamster-slam/hamster-slam.p8',
        'hamster slam',
        'hamster-slam.p8',
        "⬅️⬆️⬇️➡️ move player one's hamster (green hamster ball)\nesdf in 2-player mode, move player two's hamster (red hamster ball)\np pause menu. allows selecting 2 player mode and activating/deactivating super bounce mode\n❎ start a new game when round ends",
        'knock the other hamster balls out of the ring!',
        "◝○ネ◝oル●2tヌょン◝?Hノ!ラ◝░ュ⁴ンよE~♪ュか\"よG◜/➡️◝Gノ◝▮ン◝D◜ヒ◝わよラ○ネO◜○ュん◝➡️よヲ○ラᶠ◝W◜…◝/7◝g◜◝ᶠ◝o◜7▥░◝ᵇ◝⬇️ケ◝█◝♪#ュ_ヲ7⁙=るよュ゜ムオ◝ᵇ◝⬅️8◜ᶠ➡️ユ◝/ヲ▥ゃ◝░◝ゃrヲかっ◝a▮◜ᶠニヤ<◀◜ヤCれ◝⬇️○り⁙◜ヤなヨ◝⁷ヘ.ン◝ャa▥ノはユ'?せなJ\"▶웃◝gヒ☉ᶠラ\r2?&◜え」!ュ,ニ○ハッˇ◝い◜l◝せ웃_ハ◝⧗	\r○&◜'	•ら_のユ○I\000ヲ♪ゃ◝トHュ❎Sる◝D゛◜◝Eヲ7♥◝✽|ュ⧗▥シヨゅュかRよス4웃◝✽もュしょミ◝∧ヲIメ…◝⁵○ユ³ホ⬅️◝⁵ヲ▒◝○➡️ク/9$ュ.○ヨ○ノ?◜○ュゃ◝♪○はュか\"○G◜?ュ゜◀ン○D◜/➡️ト#◝せっに➡️◝•ノ'っ◝⧗っCノg"
    ),
    -- end hamster-slam
                                                                                                                                -- separator
    -- begin grow-big-or-go-home
    makeGame(
        '/carts/grow-big-or-go-home/grow-big-or-go-home.p8',
        'grow big or go home',
        'grow-big-or-go-home.p8',
        '⬅️⬆️⬇️➡️ move\n❎ start a new game when the game ends',
        'eat the other microbes to grow big...or be eaten yourself!',
        "◝○ネ◝oル⁴ネ⌂れゃ◝◝っれ◝▤#qラ?ノ⧗{➡️◝▶よ2◜?ュら_ュ?ヲ✽_Bヲ?ユ○ヌフ$◝░んゅ)よ\"ヨ⁷hヌ	゜?マにニ\rO★トbMうく🐱;\\ュろˇまら◝▒ト」◝❎ユ⁷ニ◆、あン)|チ$♥_2ネ○ら◝!⁸ニ○▮N★ヲトラ{ヌ○⁘な%◜シュうxfン)も웃⬇️トン○ユ◝Xヲ○░○れ◝◆゜Cる□?░_ヲ;q%^ユ_゛○fなア⁙◜\nセ\"ニ◝ ハ○➡️ヲかs✽◝3◝◝のれ◝,ヨよᵉᶠヲにり◆.!4はユ○L<く	ナ◝❎ヲ!❎ムャュ◝○Dヲ○e◜Mュにヲりを◝⧗かるˇヲ◝せ▥タᵉゆア◝♥ト□❎ュ◝Sn>◜○▥✽◝yまBノハナ◝\"ニ\n?$∧ン◝ユA~ナ◝⬆️り)よ リ○ニ∧か░ュ◝⁷ン_ゅ○ュ○2◆ュゃ◝dニ➡️○ン○ユユ;◝◆⁶ノ○り◝け!◝▶◜⁷3◝#~ヒ◝を○ュOン▒◝よ⁷"
    ),
    -- end grow-big-or-go-home
                                                                                                                                        -- separator
    -- begin dream-sense
    makeGame(
        '/carts/dream-sense/dream-sense.p8',
        'dream sense',
        'dream-sense.p8',
        'mouse,⬅️⬆️⬇️➡️ move crosshairs for your psychic blast\nleft click,❎ psychic blast\nright click,🅾️ toggle dream sense',
        'sense monsters from the dream world and psychic-blast them away!',
        "◝○ネ◝oルᶠHz?つ゛ᶜョ◝◝◝○∧ニかろ◝qつ?r,ラ○チᵉ○░◝gあかノ◝◝kリヲ◝ᶠqニにネs$◝に、ャ/⬅️ユ?⧗◝ ヲかセ○⁷ヌエC□◝゜ン9●◝し▮ラモ³◝ょ%モJュ?	にナ◝Yヌ◝ハᵇ◝○aた◝○▮¥◜◝◝/4ュ◝⬇️ユ?t◜ˇら◝_p◜より◝○pョよレリ◜よハs◝よリ³\000「\000\000\000\000\000\000\000\000\000●◝?ニョ◝▶ュ◝シ<◜◝C⁸◝◝ せ◝より◝◝♥ヤむラ◝゜キリ6ュ_ハ⁷ん◝シン⬇️◜◝ᵇワ◝よオ◝◝◝O³"
    ),
    -- end dream-sense
                                                                                                                                                -- separator
    -- begin pascal-rorschach-tweet
    makeGame(
        '/carts/pascal-rorschach-tweet/pascal-rorschach-tweet.p8',
        'pascal-rorschach tweet',
        'pascal-rorschach-tweet.p8',
        '❎ calculate next generation\n🅾️ copy current generation number to clipboard (i.e. how many times you have pressed the x key)',
        "rorschach test-like pascal's triangle generation",
        "◝○ネ◝o,ヲ◝トᶜ◝○█Q◜ヤ ナ○◜\000ヲよ#\000◝○█◝よ■◜◝³◝◝◝◝◝◝◝⁵●◝よ\000る◝゜⁸ニ◝ᶠ░●◝○▮◜◝¹²ユ○ᶠハ◝゛おユ;",
        true
    ),
    -- end pascal-rorschach-tweet
                                                                                                                                                        -- separator
    -- begin health-inspectre
    makeGame(
        '/carts/health-inspectre/health-inspectre.p8',
        'health inspectre',
        'health-inspectre.p8',
        '⬅️⬆️⬇️➡️ move\n❎ toggle flashlight',
        'hide in the darkness or get caught by ghosts!',
        "◝○ネ◝oルᶠぬjqᶜやえ◝◝◝◝◝◝すp4は◝は]セ4は◝iソ_のョ/s、?%ン゜n♥ON◜wヨLおアゃ◝.=Nユ✽◝▶る」n◜WMにつG🐱ク◜o★ヘにュト🐱$よ%◜wュトハ♥~゜?ユ?ツNxもヲ◝:ゃフを◝シヨz◜gY「pスミヲかレキ$ュ◝◝\000	○ゅ◝)‖◜◝◝ ュょ◝😐_ントヨ#◝C~ネ○ゃOュ★シ◝✽?ヲんヨ?ゅᶠね;ねd◝{ャ◝◝○めユ◝◝◝◝み\000"
    ),
    -- end health-inspectre
                                                                                                                                                                -- separator
    -- begin lofty-lunch
    makeGame(
        '/carts/lofty-lunch/lofty-lunch.p8',
        'lofty lunch',
        'lofty-lunch.p8',
        '⬅️⬆️⬇️➡️ move your plate\n❎ start a new game when you finish the game. also ends the game when you are in free play mode\np bring up pause menu to turn on/off free play',
        'build an epic sandwich',
        "◝○ネ◝oル⁵q|や。ッ◝s➡️ゅ◝お#ヨ○フナ◝◝◝◝よZ⁸ヲかWひュエハ◝◝◝◝⬇️:ノ웃ろ◝ョH\"➡️◝;◝◝◝◝/@³ユ?OYᶠ\"◝s[◀ラ?ト🅾️#おユ?エj♥カ◝えせiゆ^トワ%ミ◝-4uハマ|R◝ほケ゜ゃˇ~Wュエs|なヤzノヨ◝N/yろヨ?トンルナ○おヤャ◝⁙ロ◝◝◝◝\000xヲかG゛◜フゃ◜g"
    ),
    -- end lofty-lunch
                                                                                                                                                                        -- separator
    -- begin binary-minery
    makeGame(
        '/carts/binary-minery/binary-minery.p8',
        'binary minery',
        'binary-minery.p8',
        '⬅️⬆️⬇️➡️ move/drill',
        'use your drill to mine bitcoins!',
        "◝○ネ◝oル✽こ\nクュン◝◝`お█⁵░◝!W8🐱ユ○ノ◝◝ほ⧗✽ホヲ5G&Oヌゃ#こ」;ル◝、□;レ○らエくラ○!!!!!✽O◜トL◜◝@⁸➡️q3◜ニ゜F³おDB\\%웃░ノ⧗DBBBヘユ⬇️\\🅾️○、よ3ン웃○ヲ;░ユᶠほ🅾️1nゆオDBBるH⁸%⬆️░░░ひヲノ○L▤ュト■Blュれヲ♥ヨSヲ2IE>\"%🅾️◆d★G¥ュ ネ_ョん🅾️0ン▒○ンG🅾️…█9をイヲ◆かBし$ˇ<b?⧗……る'▶ネ◝んノ⁷を◝.░♥◝	ネんオ<★HHH゛I%⧗…0□□□Rヲ▤チ2◜7aR◜➡️ヨよ		○xを「▶▶?●&★Cさ░★、フ-ゃ$$さユゃヲm{おいかるノネほノぬ♥よCる_🅾️12イ/😐/$カ、★JまHHH\"웃░P□Rヲ▤ュ○▥⬆️◝u⁸よユ?ぬ⬅️゜B⁙					ゃ%웃░░➡️\\★Hニ⧗○ン◆❎ゃ◝▒◝8Cxuュ,ᶠ❎😐●&ヌ(I$♥$★G□iユ%B♥Oをイegヲx▥|チ\\r●トBるゃ○🅾️カろo!웃ヒ…LB□I%⧗0★I\"!!웃4ヲ▤チラよ\n⧗ラ◆ュにBる◝🐱○ルヌᵇM$⧗DラHH\"!▥ノ…L□▶)|2.◜⧗?れノネヌ?ン3$ュ/ン)4➡️…L□	I%➡️……………D¥|rqリ◝aラ³7◝い▮ヌま「ネ_をわ「"
    ),
    -- end binary-minery
                                                                                                                                                                                -- separator
      -- END GAMES
}

__gfx__
7aaad96a77a11122eed0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7aaa999a77a1191111e0aaaaaafaffffffffffffff9999999999494444442222000000000000000000000000000000000000000000000000000000000ccc1c1c
7aaa999a77aaaa6d1110aaaaaaafaffffffffffffff9f9999999949444444222000000000000000000000000000000000000000000000000000000000cc1c1c1
7aaa999a77aaaafd5510aaaaaaaafafaffffffffffff9f999999994944442422000000000000000000000000000000000000000000000000000000000c1c1c11
7aaa999a77aaaaaadd90aaaaaaaaafafaffffffff66666f96666699466644222000000000555550055555000555000005555555000000000000000000cc1c111
7aaa999a77aaaaaad6a0aaaaaaaaaafafaffffff6777776f6777696677766422000000005888885058885055888550058888885500000000000000000c111111
7aaa999a77aaaaaad9a0aaaaaaaaaaafafafafff6777777667776677777776260000000058888885588855888888855888888885000000000000000001c11111
7aaa999a77aaaaaad9a0aaaaaaaaaaaaaafafaff677777776777667777777666000000005999999959995599999995599955999500000000000000000c111111
7aaa999a77aaaaaad9a0aaaaaaaaaaaaaaafafaf6777677767776777767777660000000059995999599959999599995999559995000000000000000001111111
7aaa999a77aaaaaad9aa05a5aaaaaaaaaaaafafa677766776777677766666666000000005aaa55aa5aaa5aaa55555555aaaaaa50000000000000000001111111
7aaa999a77aaaaaad9aa0a5a5a5aaaaaaaaaafaf677777776777677776777767000000005aaaaaaa5aaa5aaaa5aaaa5aaa55aaa5000000000000000001111111
7aaa999a77aaaaaad9aa0555a5a5aaaaaaaaaafa677777766777667777777767000000005bbbbbb55bbb55bbbbbbbb5bbb55bbb5000000000000000001111111
7aaa999a77aaaaaad9aa0555555a5a5aaaaaaaaf677777666777667777777677000000005bbbbb555bbb55bbbbbbb55bbbbbbbb5000000000000000001111101
7aaa999a77aaaaaad9aa0555555555a5a5aaaaaa6777666f6777696777776677000000005ccc55505ccc505ccccc5005cccccc55000000000000000001111010
7aaa999a77aaaaaad9aa05555555555a5a5aaaaa66666fff66666996666646660000000055555000555550055555000055555550000000000000000001010101
aaaa999a77aaaaaad9aa05555555555555a5a5aaaaaafafaffff9999494444220000000000000000000000000000000000000000000000000000000000101010
aaaa999a77aaaaaad9aa055555555555555a5a5aaaaaafaffff9f999944442220000000000000000000000000000000000000000000000000000000001010100
aaaa999a77aaaaaaddaa055555555555555555a5aaaaaafaffff9999494444220000000000000000000000000000000000000000000000000000000000100000
aaaa9999999aaaaaddaa0555555555555555555aaaaaaaafaff9f999944442225000000000000000000000000000000000000000000000000000000001000000
99999999999aaaaaddaa700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99999999999aaaaaddaa7aa05555555555555555aaaaaaaffffff999944442225000000000000000000000000000000000000000000000000001111000000000
99ddd999999aaaaaddaa7aa055555555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000000000000000000000000000000000000000000000000bbbbbbbbbbbbb
11111999999999999999aaa055555555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbb
11111999999999999999aaa055555555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
115511111111111d999d5dd0555555551111c1cc9000001cbbbbbbbbbbbbbbbb1111c1cc9000001cbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
55dd11111111111d999544d0555555551c9cc4bc01011010bb5d67bbbbbbbbbb1c9cc4bc01011010bb5d67bbbbbbbbbbbbbbbbbbbbbbbbbbbbb5bbbbbbbbbbbb
ff66d51166d1dd111111111055555555c556bbfc01000010bb5d67bbbbbbbbbbc556bbfc01000010bb5d67bbbbbbbbbbbbbbbbbbbbbb7bbbbbb5d6bbbbb77bbb
ff66d51166d1dd111111111055555555f44bbbbc0001a000bb5d67bbbb5d667bf44bbbbc0001a000bb5d67bbbb5d667bbbbbbbbbbb167bbbbb55d667bb667bbb
ff6611116e6ff6dddd11121055555555cffbb3bc10110011bb5d667bbb5d667bcffbb3bc10110011bb5d667bbb5d667bbbbbbbbbb5d667bbbb5d6667bdd667bb
eeff1115fefff666dd512210555555551cff3dc110011001bb5dd67bbb5d667b1cff3dc110011001bb5dd67bbb5d667bbb5d667bb5d667bbbb5d667bb5dd67bb
eeff1111fefff666dd512210555555551f67fc1100000101bb5dd67bbb5d667b1f67fc1100000101bb5dd67bbb5d667bbb5d667bbb5dd7bbbbbd67bbbb5dd67b
eeff1115feffffffdd515510555555551cccc1118111000ebbb5d5bbbbb5d5bb1cccc1118111000ebbb5d5bbbbb5d5bbbbb5d5bbbbb5dbbbbbbbdbbbbbb5ddbb
eeff1115feffffffdd515210555555550000070000000000bbbbbbbbbbbb5dbb0000070000000000bbbbbbbbbbbb5dbbcccccc7c11111111bbbbbbbba5a55885
eeff1115feffffffdd515510555555550000007000003b00b5d67bbbbbbb5d670000007000003b00b5d67bbbbbbb5d67bc7cc7c713b1b311bbbbbbbba5a55225
eeff1115feffffffdd515510555555550070000008000004b5d67bbbbbb55d670070000008000004b5d67bbbbbb55d67bbbbcc7c1b313b11bbbb55bba5a55885
eeff1111fefffeefdd51551055555555d7000800008000f0b5d667bbbbb5dd67d7000800008000f0b5d667bbbbb5dd67cccccccc11111111bbbb5ddba5a55555
24ff1111fefffeefcd555510555555550000008000000000bb5d667bbb5dd67b0000008000000000bb5d667bbb5dd67bccccc7c81b31b311bbb5dd66a5a55005
44551111fe444444cd515510555555550000600000000e70bb5dd67bbb5d667b0000600000000e70bb5dd67bbb5d667bf45f888813b13b11bbb5d667a5a558c5
44551111fe444444dd5555140555555500dd440007770000bb5dd5bbbbb5d67b00dd440007770000bb5dd5bbbbb5d67bf5dfffff1111118cbb55d67ba5a55775
44ff1111fe444444dd555514055555550070700000000000bbb5bbbbbbbbdbbb0070700000000000bbb5bbbbbbbbdbbbffffffff111111c8bbbdd6bba5a55005
eeff1111fefffeefdd55551405555555bbbbbb00010bbbbbbbbbbbbb00668800bbbbbb00010bbbbbbbbbbbbb00668800bbb11555ddd1bbbbbbbbbbbbbbbbbbbb
eeff1111fefffeefdd55551405555555bbbb101010101bbbbbbbbbbb06686480bbbb101010101bbbbbbbbbbb06686480b1153ccccccd5bbbbbb11555ddd1bbbb
eeff11116efffeefdd55551405555555bbb00001010101bbbbbbbbbb66684686bbb00001010101bbbbbbbbbb66684686115dccccccccd5bbb1153ccccccd5bbb
eeff11116efffeef6d55551405555555bb0010101111111bbbbbbbbb66668866bb0010101111111bbbbbbbbb6666886615dccccccccccdbb115dccccccccd5bb
eeff11116efffeef6d55551405555555b000010101011101bbbbbbbb66336666b000010101011101bbbbbbbb66336666151ccccccccccc5b15dccccccccccdbb
eeff11116efffeef6d55551405555555b000101011116111bbbbbbbb636f3666b000101011116111bbbbbbbb636f3666151cccccccccccdb151ccccccccccc5b
eeff11116efffeef6d555514055555550000010101167d110bbbbbbb03f636600000010101167d110bbbbbbb03f636601d11cccccccccc5b1d11ccccccccccdb
eeff11116efffeef6d55551405555555000010101111d1111bbbbbbb00336600000010101111d1111bbbbbbb0033660051d1dcccccccc75b51d1dccccccccc5b
eeff11556efffeef6d5555140555555500000101010111010bbbbbbb0555555000000101010111010bbbbbbb05555550b1ddd3cccccc765bb1ddd3ccccccc65b
eeff11156efffeef6d5555140555555500000010111111111bbbbbbb050aaa5000000010111111111bbbbbbb050aaa50bb15dcccccc67dbbbb15dcccccc67dbb
eeff11156efffeef6d5555140555555500000101010101010bbbbbbb05aaaa5000000101010101010bbbbbbb05aaaa50bbb55dccccccdbbbbbb55dccccccdbbb
eeff11156efffeeffd55551405555555b000001010101010bbbbbbbb05aa0050b000001010101010bbbbbbbb05aa0050bbbbb5555555bbbbbbbbb5555555bbbb
eeff11156efffeeffd55551405555555b000000001010101bbbbbbbb050aaa50b000000001010101bbbbbbbb050aaa50bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
eeff11156efffffffd55251405555555bb0000001010101bbbbbbbbb01155550bb0000001010101bbbbbbbbb01155550bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
eeff11156efffffffd55251405555555bbb00000000000bbbbbbbbbb0d65aec0bbb00000000000bbbbbbbbbb0d65aec0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
eeff11156efffffffd55551405555555bbbb000000001bbbbbbbbbbb05555550bbbb000000001bbbbbbbbbbb05555550bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
ffff11156efff66ff555551405555555bbbbbb00000bbbbbb0000000006ee600bbbbbb00000bbbbbb0000000006ee600444444441111111111111111cccccccc
ffff11156effff6ff555551405555555bbbbbbbbbbbbbbbb0060c06006e66e60bbbbbbbbbbbbbbbb0060c06006e66e60ff4ff4ff11d1e14101110111cc4ccccc
ffff11156efffffff555551805555555bbbbbbbbbbbbbbbb00000000666ee666bbbbbbbbbbbbbbbb00000000666ee666ff4ff4ff3333333300100110cc4ccccc
ffff51156efffffff555251805555555bbbbbbbbbbbbbbbb0c08060663666646bbbbbbbbbbbbbbbb0c080606636666464d44444433c393c301170010cdddcccc
ffff51156efffffff555552805555555bbbbbbbbbbbbbbbb00000000366c6666bbbbbbbbbbbbbbbb00000000366c6666000ff4ff3333333300400101cccccccc
ffff51156efffffff555552805555555bbbbbbbbbbbbbbbb0060806066666116bbbbbbbbbbbbbbbb0060806066666116f04654af33e34323040090006cccccc6
ffff51156efffffff555552805555555bbbbbbbbbbbbbbbb0000000006661160bbbbbbbbbbbbbbbb000000000666116044456000333333330008a50066cccc66
ffff55156efffffff555552805555555bbbbbbbbbbbbbbbb0000000000666600bbbbbbbbbbbbbbbb000000000066660044444404333333330050d00066666666
eeff5515deffffcff555552805555555bbbbb44444bbbbbbbbbbbbbbbbbbbbbbbbbb244dddbbbbbbbbbbbbbbbbbbbbbb0000000088ccc333377666c77c333331
eeff5515deffff7ff551552205555555bbb44aaaaafbbbbbbbbbb44444bbbbbbbb444eeeee55bbbbbbbb244dddbbbbbb0000000088ccc333c333333131133111
eeff5515defffffff555551205555555bb449aaaaaaf4bbbbbb44aaaaafbbbbbb44eeeeeeeee5bbbbb444eeeee55bbbb0000000088c66333c331333111133111
ffff5515defffffff551551205555555b449aaaaaaaaf5bbbb4a9aaaaaaf4bbbb44eeeeeeeeee5bbb44eeeeeeeee5bbb0000000022c66cccc331111333ccccc3
ffff5515defff6d66551521205555555444aaaaaaaaaafbbb4a9aaaaaaaaf5bb44eeeeeeeeeefdbbb44eeeeeeeeee5bb0000000022c6666dc33311133cccccc3
ffff5515defff6ddd511e41220555555444aaaaaaaaaafbb444aaaaaaaaaafbb44eeeeeeeeeeffbb44eeeeeeeeeefdbb0000000222cccddd66cc111c777ccccc
ffff5515de6dd55552eee212205555554449aaaaaaafafbb444aaaaaaaaaafbb444eeeeeeeefffbb44eeeeeeeeeeffbb0000000222cccc3333d63ccc777ccccc
ffff5515deddd5151e22222220555555b4449aaaaffaafbb4449aaaaaaafafbb444eeeeeeef7e7bb444eeeeeeeefffbb0000000222ccccc3335d6677777ccccc
ffff5515ddd1111eee22222220555555b49999aaaaaaa5bbb4449aaaaffaa5bbb444eeeee77e77bbb444eeeeeefe77bb0000000222cccccccc3155ccccc33ccc
ff665515511511e22222222220555555bb49aaaaaaa45bbbbb49aaaaaaa45bbbb4ee4eeeffef7bbbb4ee4eeeffef7bbb0000000222cccccccccc5555cccc7777
ff665511111e9e221822112220555555bbb44aaaaa45bbbbbbb44aaaaa45bbbbbb4eeeeeef77bbbbbb4eeeeeee77bbbb0000000222ccccccccccccc5552c7777
fdf65511141e9e111822222210555555bbbbb44444bbbbbbbbbbb44444bbbbbbbbb4444ff7bbbbbbbbb4444ff7bbbbbb0000000222ccccccccccccccc122d773
f5551144444222222822222210555555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000000222cccccccccccccccc122773
1111d444482111822222112110555555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000000111c77cccccccccccc3222f73
51114422421222222222222110555555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000000111c7acccccccccccc3222571
1169ee22211882112221221110555555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000000ddd6ddaa3cccccccc69222213
eee42111188212222121221110555555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000000ddd9ddaa3cccccccc69999993
ee112222222122822121111110555555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000000111dd57a3cccccccc66666333
ee112222222122821222111110555555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000000111dd5aa3cccccccc66666333
21112821122221121111111110555555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000000111111dd1ccccccc666ccccc3
112222111222222211111111d0555555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000000dddddd11111cccccc667aaab1
82222222222111111111111dd0555555555555555555aaaaaaaffffff999944442222eeeedddddcccccc1111111000000000000dddddd11111cccccc777aafd1
8222222222222111111111d0000000000000000000000000000000000000000000000000000000000000000000000000000000000ddddd1111113ccc777aa942
211122221221111111111d055555555555555555555aaaaaaaaffffffff9994442222eedddddddcdcccccc11111100000000000000dddddddd1111332888888c
11122211111111111111105555555555555555555555aaaaaafaffffff9999944422eeeedddddddcdcccc1c11110100000000000000ddddddd1111338888888c
12221222211111111111d0555555555555555555555aaaaaaaaffffff9f9994942222eedddddddcdcccccc111111000000000000000ddddddddd1111ddd55113
2221122211111111111d0555555555555555555555a5aaaaaafaffff9f9994942422eeeedddddddcdcccc1c111101000000000000000dddddddd1111ccc31113
2112222111111111111055555555555555555555555aaaaaafaffffff999994442222eededddddcdcccccc111111000000000000000001111111dddd11111111
111222211111111111105555555555555555555555a5aaaaaafaffff9f9994942222eeeedddddddcdcccc1c11110100000000000000001111111dddd11111111
12222111111111111105555555555555555555555a5aaaaaafaffff9f999494222222eeeedddddcdcccccc11111100000000000000000011111111dd11dd4111
2222111111111111105555555555555555555555a5aaaaaaaaffff9f999494242222eeeedddddddcdcccccc1111010000000000000000001111111dd11dd1111
222111111111111110555555555555555555555a5a5aaaaaaffffff9f949424222222eeeedddddcdcccccc1111110000000000000000000111111111dddddddd
21221111111111110555555555555555555555a5a5aaaaaafaffff9f999494222222eeeededddddcccccccc111111000000000000000000011111111dddddddd
1122111111111110555555555555555555555a5a5aaaaaaaaffff9f99949422222222eeeedddddddcccccc1c1111010000000000000000000111111111dddddd
11111111111dddd055555555555555555555a5a5aaaaaaaaffffff9f949422222222eeeeeedddddcdcccccc11111100000000000000000000ddddddddd111111
1111111111dddd055555555555555555555a5a5a5aaaaaafaffff9f94942422222222eeeededddddcccccc1c11110100000000000000000000dddddddddd1111
11111111dddddd05555555555555555555a5a5a5aaaaaafaffff9f99942422222222e2eeeedddddcdcccccc1c1111010000000000000000000dddddddddd1111
11111111ddddd05555555555555555555a5a5a5aaaaaafaffff9f9994942222222222eeeeeedddddcccccccc111101010000000000000000000ddddddddddd11
111111dddddd05555555555555555555a5a5a5aaaaaaffffff9f999994242222222222eeeedddddddcccccc1c111101010000000000000000000dddddddddd11
111111dddddd0555555555555555555a5a50000000aafffff9f999994242222222222eeeeeedddddcdcccccc1c11110101010000000000000000dddddddddddd
11111dddddd0555555555555555555a5a00000000000afff9f99999424222222222222eeeeeedddddcdcccc1c1111110101010100000000000000ddddddddddd
1111dddddd05555555555555555a5a5a0000101010101ff9f99999424222222222222e2eeeedddddddcccccc1c1111110101010100000000000000dddddddddd
111ddddd110555555555555555a5a5a0000101111101009f9999999424222222222222eeeeeedddddcdcccccc1c111111110101010000000000000dddddddddd
111ddddd105555555555555a5a5a5a000010111111101019999999444222222222222e2eeeeeedddddcdcccccc1c111111110101010100000000000ddddddddd
1111111110555555555555a5a5a5aa0000010111110100099999944424222222222222eeeeeededddddcccccccc1c11111111110101010100000000111111111
111111111055555555555a5a5aaaaa00001011111110101999994942422222222222222eeeeeedddddcdcccccccc1c1111111111110101010100000111111111
111111111055555555a5a5aaaaaaaaa000010101010100999999944424222222222222e2eeeeeedddddcdcccccccc1c111111111111110101010000111111111
11111111105a5a5a5a5a5aaaaaaaaaff001010101010199999994442422222222222222eeeeeedddddddcdcccccccc1c11111111111111110101000111111111
1111111110a5a5a5a5aaaaaaaafffffff000000100009999999444242222222222222222eeeeeedddddcdcccccccccc1c1111111111111111111100111111111
111111110a5aaaaaaaaaaafafffffffffff010101099999999444442422222222222222e2eeeeeedddddcdcccccccccc1c111111111111111111111011111111
111111110aaaaaaaafafafffffffff9ffff9999999999999949444242222222222222222e2eeeedddddddcdcccccccccc1c11111111111111111111011111111
111111110aaaaafafaaafffffffff9f999999999999999494944424222222222222222222eeeeeedddddcdcccccccccc1c1c1111111111111111111011111111
1111111d0fafafafafafffffff9f9f999999999999999494944424242222222222222222e2eeeeeedddddcdcccccccccc1c1c111111111111111111011111111
111111110afafafffffffff9f9f9f99999999999999949444444424222222222222222222e2eeeeeddddddcdcccccccccccc1c1c111111111111111011111111
111111110fffffffffff9f9f9f999999999999999494944444442422222222222222222222e2eeeedddddddcdcccccccccccc1c1c11111111111111011111111
11111110fffffffffff9f9f9999999999999994949494444444242222222222222222222222e2eeeddddddddcccccccccccccc1c1c1111111111111101111111
11111110fffff9ffff9f999999999999999494949494444444242422222222222222222222e2eeeeeddddddcdcccccccccccccc1c1c11111111111110ddddddd
11111110fffffff9f9f99999999999994949494444444444444242222222222222222222222e2eeeeeddddddcdcccccccccccccccc1c1c11111111110ddddddd
111111109f9f9f9f999999999999999494949444444444444424222222222222222222222222e2eeeedddddddcccccccccccccccccc1c1c1111111110ddddddd
1111111099f9f9999999999999994949494944444444444442422222222222222222222222222e2eeededdddcdcccccccccccccccccccc1c111111110ddddddd
111111099999999999999999999494949444444444444444242222222222222222222222222222e2eeededdddcdcccccccccccccccccccc1c111111110dddddd
1111110999999999999999994949494944444444444444424242222222222222222222222222222eeeeeddddddcdcccccccccccccccccccc1c11111110dddddd
11111105999999999994449494949494444444444444442424222222222222222222222222222222eeeeeddddddcccccccccccccccccccccc111111110dddddd
1111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ddddddd
__label__
500005000050000500005000050000500005000050000500005000050ddd3338333333333333333333303333333033333333333333333333333333333330ddd0
050000500005000050000500005000050000500005000050000500005ddd3336333333333333333333303333333033333333333333333333333333333330ddd0
005000050000500005000050000500005000050000500005000050000ddd3666663333333333333333303333333033333333333333333333333333333330ddd5
000500005005555500555555005550000555555550050000500005000ddd6555556333333333333333303333333033333333333333333333333333333330ddd0
000050000558888850588850558885500588888855005000050000500ddd65a5a56333333333333333303333333033333333333333333333333333333330ddd0
500005000058888885588855888888855888888885000500005000050ddd6555556333333333333333303333333033333333333333333333333333333330ddd0
050000500059999999599955999999955999559995000050000500005ddd3666663333333333333333303333333033333333333333333333333333333330ddd0
005000050059995999599959999599995999559995500005000050000ddd0000000033333333000000003333333333333333333333330000000033333330ddd5
00050000505aaa55aa5aaa5aaa55555555aaaaaa50050000500005000ddd3333333333333333333333333333333333333330333333303333333333333330ddd0
00005000055aaaaaaa5aaa5aaaa5aaaa5aaa55aaa5005000050000500ddd3333333333333333333333333333333333333330333333303333333333333330ddd0
50000500005bbbbbb55bbb55bbbbbbbb5bbb55bbb5000500005000050ddd3333333333333333333333333333333333333330333333303333333333333330ddd0
05000050005bbbbb555bbb55bbbbbbb55bbbbbbbb5000050000500005ddd3333333333333333333333333333333333333330333333303333333333333330ddd0
00500005005ccc55555ccc505ccccc5055cccccc55500005000050000ddd3333333333333333333333333333333333333330333333303333333333333330ddd5
000500005055555000555555055555000555555550050000500005000ddd3333333333333333333333333333333333333330333333303333333333333330ddd0
000050000500005000050000500005000050000500005000050000500ddd3333333333333333333333333333333333333330333333303333333333333330ddd0
500005000050000500005000050000500005000050000500005000050ddd3333333300000000000000003333333333333333000000000000000000000000ddd0
050000500005000050000500005000050000500005000050000500005ddd3333333333333330333333333333333033333333333333303333333333333330ddd0
005000050000500005000050000500005000050000500005000050000ddd3333333333333330333333333333333033333333333333303333333333333330ddd5
000500005000050000500005000050000500005000050000500005000ddd3333333333333330333333333333333033333333333333303333333333333330ddd0
066666666666666666666666666666666666666666666666660000500ddd3333333333333330333333333333333033333333333333303333333333333330ddd0
568886888688868886666688866886888666666666666666665000050ddd3333333333333330333333333333333033333333333333303333333333333330ddd0
068686866686866866666686868686686666666666666666660500005ddd3333333333333330333333333333333033333333333333303333333333333330ddd0
068866886688866866666688668686686666666666666666660050000ddd3333333333333330333333333333333033333333333333303333333333333330ddd5
068686866686866866666686868686686666666666666666660005000ddd3333333333333333333333330000000000000000000000003333333333333330ddd0
068886888686866866666688868866686666666666666666660000500ddd333333303333333033333333333333333333333033333330333c333033333330ddd0
566666666666666666666666666666666666666666666666665000050ddd333333303333333033333333333333333333333033333330333cc33033333330ddd0
050000500005000050000500005000050000500005000050000500005ddd333333303333333033333333333333333333333033333330333ccc3033333330ddd0
005000050000500005000050000500005000050000500005000050000ddd333333303333333033333333333333333333333033333330333c333033333330ddd5
000500005000050000500005000050000500005000050000500005000ddd3333333033333330333333333333333333333330333333303ccc333033333330ddd0
007770777577007770777070700005000050000500005000050000500ddd333333303333333033333333333333333333333033333330cccc333033333330ddd0
507075070070707570707070750000500005000050000500005000050ddd3333333033333330333333333333333333333330333333303cc3333033333330ddd0
057700570075707770770577705000050000500005000050000500005ddd3333333300000000000000003333333300000000333333333333333300000000ddd0
007070070070707075707050700500005000050000500005000050000ddd3333333333333333333333303333333033333333333333333333333333333330ddd5
007770777070757070707077700050000500005000050000500005000ddd3333333333333333333333303333333033333333333333333333333333333330ddd0
000050000500005000050000500005000050000500005000050000500ddd3333333333333333333333303333333033333333333333333333333333333330ddd0
507775777077007770777070750000500005000050000500005000050ddd3333333333333333333333303333333033333333333333333333333333333330ddd0
057770570075707050707570705000050000500005000050000500005ddd3333333333333333333333303333333033333333333333333333333333333330ddd0
007070070070707705770077700500005000050000500005000050000ddd3333333333333333333333303333333033333333333333333333333333333330ddd5
007570075070757000707005700050000500005000050000500005000ddd3333333333333333333333303333333033333333333333333333333333333330ddd0
007070777570707770757077700005000050000500005000050000500ddd3333333300000000000000000000000033333333000000003333333333333330ddd0
500005000050000500005000050000500005000050000500005000050ddd3333333333333333333333333333333333333330333333333333333033333330ddd0
050000500005000050000500005000050000500005000050000500005ddd3333333333333333333333333333333333333330333333333333333033333330ddd0
005000050000500005000050000500005000050000500005000050000ddd3333333333333333333333333333333333333330333333333333333033333330ddd5
000500005000050000500005000050000500005000050000500005000ddd3333333333333333333333333333333333333330333333333333333033333330ddd0
007770777507707070777000500775707077700500005000050000500ddd3333333333333333333333333333333333333330333333333333333033333330ddd0
507075707070707570705000057070707007000050000500005000050ddd3333333333333333333333333333333333333330333333333333333033333330ddd0
057700770075707750770500007070757007500005000050000500005ddd3333333333333333333333333333333333333330333333333333333033333330ddd0
007070757070707075700050007570707007050000500005000050000ddd0000000033333333333333333333333300000000333333333333333300000000ddd5
007770707077057070777005007750077507005000050000500005000ddd3333333333333330333333303333333033333333333333303333333333333330ddd0
000050000500005000050000500005000050000500005000050000500ddd3333333333333330333333303333333033333333333333303333333333333330ddd0
500005000050000500005000050000500005000050000500005000050ddd3333333333333330333333303333333033333333333333303333333333333330ddd0
050000500005000050000500005000050000500005000050000500005ddd3333333333333330333333303333333033333333333333303333333333333330ddd0
005000050000500005000050000500005000050000500005000050000ddd3333333333333330333333303333333033333333333333303333333333333330ddd5
000770777077757770777077707770777500005000050000500005000ddd3333333333333330333333303333333033333333333333303333333333333330ddd0
007050707577707070750007507075700050000500005000050000500ddd3333333333333330333333303333333033333333333333303333333333333330ddd0
507005777070707770775007057700770005000050000500005000050ddd0000000000000000000000000000000000000000000000000000000000000000ddd0
057000707075707050700507007070750000500005000050000500005ddd0ff0000000000000000000000000fff000000000000000000000000000000000ddd0
005770757070707005700077707570777000050000500005000050000dddf000fff00ff0fff0fff00f000000f0f000000000000000000000000000000000ddd5
000500005000050000500005000050000500005000050000500005000dddfff0f000f0f0f0f0ff0000000000f0f000000000000000000000000000000000ddd0
000770777577707070750077707775077077700500005000050000500ddd00f0f000f0f0ff00f0000f000000f0f000000000000000000000000000000000ddd0
507005070077707570705070750700707075700050000500005000050dddff00fff0ff00f0f0fff000000000fff000000000000000000000000000000000ddd0
057770570075707070700577705700757077500005000050000500005ddd0000000000000000000000000000000000000000000000000000000000000000ddd0
005070070070707075700070700700707070750000500005000050000ddd0000000000000000000000000000000000000000000000000000000000000000ddd5
007700777070750770777075700750770570705000050000500005000ddd0000000000000000000000000000000000000000000000000000000000000000ddd0
000050000500005000050000500005000050000500005000050000500dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0
500005000050000500005000050000500005000050000500005000050d00000000000000000000000000000000000000000000000000000000000000000000d0
050000500005000050000500005000050000500005000050000500005d07770707077700000777007707770077077700000077077007000707000000000000d0
005000050000500005000050000500005000050000500005000050000d00700707070000000707070707070707007000000707070707000707000000000000d5
000770777077057700577077007770707577705770050000500005000d00700777077000000770070707700707007000000707070707000777000000000000d0
007050707570707070757070707075707070707500005000050000500d00700707070000000707070707070707007000000707070707000007000000000000d0
507005777070707570707070757700707077007770000500005000050d00700707077700000707077007770770007000000770070707770777000000000000d0
057000707075707070707570707070757070700075000050000500005d00000000000000000000000000000000000000000000000000000000000000000000d0
005770757070707075770070707770077077757700500005000050000d07770777007707770077077007700077000007770077000000000000000000000000d5
000500005000050000500005000050000500005000050000500005000d07070700070007070707070707070700000000700707000000000000000000000000d0
000050000500005000050000500005000050000500005000050000500d07700770077707770707070707070777000000700707000000000000000000000000d0
500005000050000500005000050000500005000050000500005000050d07070700000707000707070707070007000000700707000000000000000000000000d0
050000500005000050000500005000050000500005000050000500005d07070777077007000770070707770770000000700770000000000000000000000000d0
005770077007707005000057707770777000050000500005000050000d00000000000000000000000000000000000000000000000000000000000000000000d5
007500707070757000500075007070070500005000050000500005000d00770077077707770777077007700077000007070707077707700000000000000000d0
007050707570707000050070507775070050000500005000050000500d07000707077707770707070707070700000007070707070007070000000000000000d0
507005707070707500005070057070570005000050000500005000050d07000707070707070777070707070777000007070777077007070000000000000000d0
050770770077007770000507707070070000500005000050000500005d07000707070707070707070707070007000007770707070007070000000000000000d0
005000050000500005000050000500005000050000500005000050000d00770770070707070707070707770770000007770707077707070000000000000000d5
000770777077757770500005000050000500005000050000500005000d00000000000000000000000000000000000000000000000000000000000000000000d0
007050707570007000050000500005000050000500005000050000500d07770707077707070000077707770777000007770770000007770777077707770000d0
507005777077007700005000050000500005000050000500005000050d00700707070007070000070707070700000000700707000000700070077707000000d0
057000707075007050000500005000050000500005000050000500005d00700777077007770000077707700770000000700707000000700070070707700000d0
005770757070507775000050000500005000050000500005000050000d00700707070000070000070707070700000000700707000000700070070707000000d5
000500005000050000500005000050000500005000050000500005000d00700707077707770000070707070777000007770707000000700777070707770000d0
000050000500005000050000500005000050000500005000050000500d00000000000000000000000000000000000000000000000000000000000000000000d0
500005000050000500005000050000500005000050000500005000050d07070777077707070000077707070777000007770707007707770077000000000000d0
050000500005000050000500005000050000500005000050000500005d07070070007007070000007007070700000007770707070000700700000000000000d0
005770077070707705777077000770707077050000777007700050000d07070070007007770000007007770770000007070707077700700700000000000000d5
007500707070757070570075707070707570705000070070700005000d07770070007007070000007007070700000007070707000700700700000000000000d0
007050707570707070070070707075707070700500075070750000500d07770777007007070000007007070777000007070077077007770077000000000000d0
507005707070707570075070757070777075700050070570705000050d00000000000000000000000000000000000000000000000000000000000000000000d0
050770770007707070070577707700777070700005070077000500005d00000000000000000000000000000000000000000000000000000000000000000000d0
005000050000500005000050000500005000050000500005000050000d00000000000000000000000000000000000000000000000000000000000000000000d5
007770777070057770770007707070770500005000050000500005000d00000000000000000000000000000000000000000000000000000000000000000000d0
007770700570005700757070707075707050000500005000050000500d00000000000000000000000000000000000000000000000000000000000000000000d0
507075770070000700707070757070707005000050000500005000050d00000000000000000000000000000000000000000000000000000000000000000000d0
057070700075000750707570707770757000500005000050000500005d00000000000000000000000000000000000000000000000000000000000000000000d0
007070777077700705777077007770707000050000500005000050000d00777770007777700077777000777770000007770077070707770000000000000000d5
000500005000050000500005000050000500005000050000500005000d07770077077707770770007707700777000007770707070707000000000000000000d0
000050000500005000050000500005000050000500005000050000500d07700077077000770770007707700077000007070707070707700000000000000000d0
500005000050000500005000050000500005000050000500005000050d07770077077000770777077707700777000007070707077707000000000000000000d0
050000500005000050000500005000050000500005000050000500005d00777770007777700077777000777770000007070770007007770000000000000000d0
007700777077707775770057707770077077057770700005000050000d00000000000000000000000000000000000000000000000000000000000000000000d5
007570075077757000707075000750707570707070750000500005000d07770000077707770707007707770000000000000000000000000000000000000000d0
007070070570707700757077700705707070707770705000050000500d07070000070707070707070007000000000000000000000000000000000000000000d0
507075070070707500707000750700707075707070700500005000050d07770000077707770707077707700000000000000000000000000000000000000000d0
057770777075707770707577007770770070707075777050000500005d07000000070007070707000707000000000000000000000000000000000000000000d0
005000050000500005000050000500005000050000500005000050000d07000000070007070077077007770000000000000000000000000000000000000000d5
007700777070057770577075707770077500005000050000500005000d00000000000000000000000000000000000000000000000000000000000000000000d0
007070700570005700750070700705700050000500005000050000500d00000000000000000000000000000000000000000000000000000000000000000000d0
507075770070000700705077750700777005000050000500005000050d00000000000000000000000000000000000000000000000000000000000000000000d0
057070700075000750707570705700057000500005000050000500005d00000000000000000000000000000000000000000000000000000000000000000000d0
007770777077707775777070700700775000050000500005000050000d00000000000000000000000000000000000000000000000000000000000000000000d5
000500005000050000500005000050000500005000050000500005000d00000000000000000000000000000000000000000000000000000000000000000000d0
000050000500005000050000500005000050000500005000050000500d00000000000000000000000000000000000000000000000000000000000000000000d0
500005000050000500005000050000500005000050000500005000050d00000000000000000000000000000000000000000000000000000000000000000000d0
050000500005000050000500005000050000500005000050000500005d00000000000000000000000000000000000000000000000000000000000000000000d0
007700777077700775077077000500005000050000500005000050000d00000000000000000000000000000000000000000000000000000000000000000000d5
007570707070757000707075700050000500005000050000500005000d00000000000000000000000000000000000000000000000000000000000000000000d0
007070770577707000757070700005000050000500005000050000500d00000000000000000000000000000000000000000000000000000000000000000000d0
507075707070707570707070750000500005000050000500005000050d00000000000000000000000000000000000000000000000000000000000000000000d0
057770707075707770770570705000050000500005000050000500005d00000000000000000000000000000000000000000000000000000000000000000000d0
005000050000500005000050000500005000050000500005000050000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd5

__gff__
0000010101010101010101010101010100000101010101010101010101010101000001010101010101010101010101010000010101010101010101010101010100000101010100000101000001000101000001010101000001010000000001010000010101010000010100000000010100000101010100000101000000000101
0000010101010101010101010100000000000101010101010101010101000000000001010101010101010101010000000000010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
__map__
000102030405060708090a0b0c0d0e0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
101112131415161718191a1b1c1d1e1f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
202122232425262728292a2b2c2d2e2f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
303132333435363738393a3b3c3d3e3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
404142434445464748494a4b4c4d4e4f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
505152535455565758595a5b5c5d5e5f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
606162636465666768696a6b6c6d6e6f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
707172737475767778797a7b7c7d7e7f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
808182838485868788898a8b8c8d8e8f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
909192939495969798999a9b9c9d9e9f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a0a1a2a3a4a5a6a7a8a9aaabacadaeaf00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b0b1b2b3b4b5b6b7b8b9babbbcbdbebf00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0c1c2c3c4c5c6c7c8c9cacbcccdcecf00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0d1d2d3d4d5d6d7d8d9dadbdcdddedf00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0e1e2e3e4e5e6e7e8e9eaebecedeeef00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f0f1f2f3f4f5f6f7f8f9fafbfcfdfeff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010f000005135051050c00005135091351c0150c1351d0150a1351501516015021350713500000051350000003135031350013500000021351b015031351a0150513504135000000713505135037153c7001b725
010f00000c03300000300152401524615200150c013210150c003190151a01500000246153c70029515295150c0332e5052e5150c60524615225150000022515297172b71529014297152461535015295151d015
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
game_name: Picade Simulator
jam_info: []
develop_time: null
img_alt: Small arcade cabinet listing several games the user can play
# Leave blank to use game-name
game_slug: 
tagline: Play all your favorite PICO-8 games in one place!
description: |
  Simulate the experience of playing games on hardware!
  Includes 12 games!
controls:
  - inputs: [UP_ARROW_KEY, DOWN_ARROW_KEY]
    desc:  Move selection up and down
  - inputs: [X]
    desc:  Choose game
  - inputs: [P]
    desc: Pause menu. When playing a game use "Back to Picade" option to get back to main menu
hints: ''
acknowledgements: |
  Based on the [Picade](https://shop.pimoroni.com/products/picade) mini arcade cabinet by Pimorini
  
  Music on menu is from [Gruber](https://www.lexaloffle.com/bbs/?uid=11292)'s [Pico-8 Tunes Vol. 1](https://www.lexaloffle.com/bbs/?tid=29008), Track 5 - Ice. 
  Licensed under [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/)

  Arcade background image generated with [Dalle-2](https://openai.com/dall-e-2/)

  Visit [game pages](https://caterpillargames.itch.io/) for acknowledgements for individual games
to_do: 
  - Draw labels
  - print descriptions
  - make 128x128
  - The scrolling is still not great
  - Load from other carts
version: 0.1.0
release_notes: ''
number_players: [1,2]
__meta:cart_info_end__