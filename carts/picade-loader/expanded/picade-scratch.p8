pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
-- pico arcade
-- by that tom hall & friends
-- a launcher for all pico-8
-- demake/remake arcade games
-------------------------------
-- please excuse the crappy coding.
-- just wanted to get it done! 😐
-------------------------------
function _init()
  gs = {
    index = 1,
    scroll_y = 0,
    games = {
      "cannonbubs",
      "pursuit-in-progress",
      "toxic-toads",
      "tile-isle",
      "hamster-slam",
      "cool-cat-cafe"
    },
    game_desc = {
      "cannonbubs",
      "pursuit in\n progress",
      "toxic toads",
      "tile isle",
      "hamster slam",
      "cool cat cafe"
    }
  }
	--direction and walk anim
	north=1
	east=2
	south=3
	west=4
	walkspeed=1
	walkframe=1 -- not used really
 -- animation counters
	twoframe=0 --two frame anims
 threeframe=2 -- three frame anims
	fourframe=1 -- four frame anims
 fiveframe=3 -- five frame anims
 sixframe=4 -- six frame anims
 maxdelay=16
 framedelay=maxdelay-1
 
 frame60=0
 -- data for all the carts! 
 cartnum=1
 cart={"pzone",
       "missile command",
       "piconian",
       "webpilot",
       "galactic wars",
       "omega zone",
       "p-tapper",
       "wizards rule",
       "pico racer",
       "invasion",
       "super hot pellet muncher 2000",
       "space picanoid",
       "breakout hero",
       "just one boss",
       "celeste",
       "magic bubble",
       "pico tetris",
       "invaders 2600",
       "pakutto boy",
       "picoman",
       "invader overload",
       "sewers of d'oh!",
       "mystic realm dizzy",
       "marballs 2",
       "mistigri",
       "heat death",
       "combo pool",
       "cosmo boing deluxe",
       "pico frogger",
       "tetyis",
       "centipede",
       "worm nom nom",
       "loose gravel",
       "tie hunt",
       "no tomorrow"
       }
 author={"hwd2002",
         "lummi",
         "aquova",
         "tesselode",
         "bigchanguito",
         "kometbomb",
         "milkymalk",
         "gadzooka",
         "kometbomb",
         "netvip3r",
         "ultrabrite",
         "arashi256",
         "krystman",
         "bridgs",
         "matt&noel",
         "jwinslow23",
         "vanessa",
         "pahammond",
         "konimiru",
         "urbanmonk",
         "morningtoast",
         "ultrabrite",
         "sophie houlden",
         "lucatron",
         "benjamin soule",
         "gate88",
         "nusan",
         "minsoft",
         "pahammond",
         "spaz48",
         "lummi",
         "kometbomb",
         "mot",
         "minsoft",
         "cesco"
       }
 cartname={"#62288",
       "#64085",
       "#54876",
       "#55986",
       "#37065",
       "#36863",
       "#34661",
       "#17568",
       "#19673",
       "#19676",
       "#43819",
       "#38726",
       "#53976",
       "#49232",
       "#15133",
       "#magic_bubble",
       "#picotetris",
       "#invaders09",
       "#28218",
       "#11437",
       "#42220",
       "#46281",
       "#41286",
       "#46032",
       "#21603",
       "#g88_heatdeath",
       "#26895",
       "#47369",
       "#picofrogger",
       "#spaz48_tetyis",
       "#centipede",
       "#23208",
       "#loose_gravel",
       "#46690",
       "#46052"
       }
 cartsprite={128,130,132,134,136,138,140,142,
             160,162,164,166,166,170,172,174,
             192,194,164,164,200,
             224,226,228,230,232,234,236,238,
             192,168,196,160,198,130}
 --
 wallpos=0
 ----------------------------
 -- state to show off interesting
 gs_idle=0
 gs_title=1
 gs_showcarts=2
 gs_thanks=3
  
 -- set up demo data
 init_stars()
 game={}
 game.state=gs_title 

 frame_counter=0
 -- for ord and chr, sprint
 setup_asciitables()

 music(0)

end

--------------------------------
function init_stars()
 -- stars for space stuff
 -- you have to declare tables
 -- with ={} or their direct contents
 starsx={} -- x location of star
 starsy={} -- y location of star
 starsc={} -- color of star (darker = moves slower)
 numstars=40 -- decent number for not cluttery
 for i=1,numstars do
  starsx[i]=rnd(128) -- 0-127
  starsy[i]=rnd(128) -- 0-127
  --colors dark gray, light gray, white
  starsc[i]=5+flr(rnd((i%3)+.5)) -- 5, 6, 7 
  -- this with be 5, 6, or 7 without a fractional part
  -- i added +.5 to get more foreground stars
 end
 -- pick a direction! 0-3
 -- 0= up
 -- 1= upright
 -- 2= right
 -- 3= downright
 -- 4= down
 -- 5= downleft
 -- 6= left
 -- 7= upleft
 stars_direction=flr(rnd(8)) -- 0-7 integers
end
----------------------------
-- sets up ascii tables
-- by yellow afterlife
-- https://www.lexaloffle.com/bbs/?tid=2420
-- btw after ` not sure if 
-- accurate
function setup_asciitables()
 chars=" !\"#$%&'()*+,-./0123456789:;<=>?@abcdefghijklmnopqrstuvwxyz[\\]^_`|██▒🐱⬇️░✽●♥☉웃⌂⬅️🅾️😐♪🅾️◆…➡️★⧗⬆️ˇ∧❎▤▥~"
 -- '
 s2c={}
 c2s={}
 for i=1,#chars do
  c=i+31
  s=sub(chars,i,i)
  c2s[c]=s
  s2c[s]=c
 end
end
---------------------------
function asc(_chr)
 return s2c[_chr]
end
---------------------------
function chr(_ascii)
 return c2s[_ascii]
end


-->8
-- update tab
-------------------------------
function save_header()

  if not btnp(5) then
  -- if true then
    return
  end
  local ret = ''
  local mymap = {
    [0]=0,
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    'a',
    'b',
    'c',
    'd',
    'e',
    'f'
  }
  -- for y = 12*8, 128 do
    -- for x = 0, 127 do
  for y = 0, 127 do
    for x = 0, 127 do
      local thisval = mymap[pget(x,y)]
      -- if 32 <= x and x <= 96 and
      --    21 <= y and y <= 21 + 64 then
      --   thisval = ' '
      -- end
      ret = ret .. thisval
    end
    -- ret = ret .. '\n'
  end
  printh(ret, '@clip')
  return ret
end

function _update60()
  save_header()
 local old_gs, temp
 
 old_gs=game.state
 -- update state, check input
 framedelay-=1
 if (framedelay==0) then
  twoframe = (twoframe+1) % 2 --two frame anims
  threeframe = (threeframe+1) % 3 --two frame anims
  fourframe = (fourframe+1) % 4 -- four frame anims
  fiveframe = (fiveframe+1) % 5 -- five frame anims
  sixframe = (sixframe+1) % 6 -- six frame anims
  framedelay=maxdelay
  --scroll_tile(16) -- scroll water down
 end --framedelay
 frame60 = (frame60+1) % 60

 move_stars(stars_direction)
 if (btnp(⬅️)) then
  if (cartnum==1 and game.state==gs_showcarts) or (game.state!=gs_showcarts) then
	  game.state -= 1
	  if (game.state==gs_showcarts) cartnum=#cart
	  stars_direction=7-stars_direction
	  if (game.state<1) game.state=gs_thanks 
  elseif (game.state==gs_showcarts) then
    cartnum-=1
    poop=stars_direction
    stars_direction=flr(rnd(8))
    if (stars_direction==poop) stars_direction=7-poop
  end
 --end
 elseif (btnp(➡️)) then
  if (cartnum==#cart) or (game.state!=gs_showcarts) then
   game.state += 1
	  if (game.state==gs_showcarts) cartnum=1
	  stars_direction=7-stars_direction
   if (game.state>gs_thanks) game.state=gs_title 
  elseif (game.state==gs_showcarts) then
    cartnum+=1
    poop=stars_direction
    stars_direction=flr(rnd(8))
    if (stars_direction==poop) stars_direction=7-poop
  end
 elseif btnp(2) then
  gs.index -= 1
 elseif btnp(3) then
  gs.index += 1
 elseif (btnp(❎)) then
  load(gs.games[gs.index] .. '.p8', "back to picade")
  -- load(cartname[cartnum],"back to arcade")
  -- local noop = nil
 end -- if btn
  -- change music on state change
 if (old_gs != game.state) then
  if (game.state == gs_showcarts) then music(6)
  elseif (game.state==gs_title) then music(0)
  elseif (game.state==gs_thanks) then music(25) -- 29
  end -- state
 end -- gamestate
end -- fn


----------------------------
function move_stars(direction)
 for i=1,numstars do
  -- here we see what direction we are moving the stars
  -- for up, we subtract the movement in y direction
  -- for others, the same x and y, plus or minus
  -- for a final version, i'd have a "move table"
  -- containing the deltax and deltay, but this will
  -- be a lot clearer what we are doing
  move=(starsc[i]-4)/2 -- how far to move this star
  if (direction==0) then -- up
   starsy[i]=(starsy[i]-move)%128
  elseif (direction==1) then -- upright
   starsx[i]=(starsx[i]+move)%128
   starsy[i]=(starsy[i]-move)%128
  elseif (direction==2) then -- right
   starsx[i]=(starsx[i]+move)%128
  elseif (direction==3) then -- down right
   starsx[i]=(starsx[i]+move)%128
   starsy[i]=(starsy[i]+move)%128
  elseif (direction==4) then -- down
   starsy[i]=(starsy[i]+move)%128
  elseif (direction==5) then -- down left
   starsx[i]=(starsx[i]-move)%128
   starsy[i]=(starsy[i]+move)%128
  elseif (direction==6) then -- left
   starsx[i]=(starsx[i]+move)%128
  elseif (direction==7) then -- up left
   starsx[i]=(starsx[i]-move)%128
   starsy[i]=(starsy[i]-move)%128
  end
 if (frame60==0 and game.state == gs_explodestars) stars_direction=flr(rnd(8))
 end
end
-->8
--draw tab

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

-------------------------------
function _draw()
 -- cls()
 -- draw_stars()
 palt(0,false)
 palt(11, false)
 cls(13)
 sspr(0,0,128,128,0,0)
 -- map(0,0,0,0,16,16)
 -- Top Bar (picade text)
 sspr(17,0,128,21,17, 0)

 -- Left Bar
 sspr(18, 0, 14, 96, 18, 0)

 -- right bar
 sspr(96, 0, 9, 96, 96, 0)

 -- bottom console part 1
 sspr(17, 85, 95, 30, 17, 85)

 -- bottom console part 2
 sspr(0, 96, 128, 32, 0, 96)

  -- sspr(8,0,)

-- TODO add back
 draw_joystick()

 -- sprintxy("   picade",19,6,1)
 -- sprintxy("   picade",19,5,7)
 -- pal(11, 13, 1)
 palt()
 -- if (fourframe==0 and flr(time()%2)==1) spr(13,16,112,3,2)
 -- if (fourframe==1 and flr(time()%2)==1) spr(42,16,112,3,2)
 -- if (fourframe==2 and flr(time()%2)==1) spr(45,16,112,3,2)
 -- if (fourframe==3 and flr(time()%2)==1) spr(55,16,112,3,1)
  -- spr(0,10,8)
  -- spr(0,110,8)
  palt(14, true)
  -- spr(48+twoframe,48,115)
  -- spr(50+twoframe,64,115)
  -- spr(53+twoframe,96,115)
  palt()
  draw_ui()

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

function draw_ui()

  rectfill(
    32,
    21,
    32+64-1,
    21+64-1,
    6
    )

  local y = 24 -- + 10 * (i-1)
  for i = 1, #gs.games do
  -- for game in all(games) do
    local game = gs.games[i]
    local desc = gs.game_desc[i]
    print(desc, 38, y, 8)
    if i == gs.index then
      print('>', 34, y,8)
    end
    y += 10 + (measure_text_height(desc)-1) * 5
  end

end

----------------------------
-- function draw_stars()
--   -- draw stars color c at x,y
--   for i=1,numstars do
--    pset(starsx[i],starsy[i],starsc[i])
--   end
-- end
-- ----------------------------
-- function draw_boxes()
--   -- draw stars color c at x,y
--   for i=1,numstars do
--    spr(186,starsx[i],starsy[i]) -- ,starsc[i]
--   end
-- end




-->8
-- support library
-------------------------------
-- scroll tile
-- see that water tile?
-- this scrolls it down by 1
-- function scroll_tile(_tile)
--  local temp
--  local sheetwidth=64 -- bytes
--  local spritestart=0 -- starts at mem address 0x0000
--  local spritewide=4 -- 8 pixels=four bytes
--  local spritehigh=sheetwidth*8 -- how far to jump down
--  local startcol=_tile%16
--  local startrow=flr(_tile/16)
 
--  if (_tile>255) return
--  -- save bottom row of sprite
--  temp=peek4(spritestart+(startrow*sheetwidth*8)+(7*sheetwidth)+startcol*spritewide) -- 7th row
--  for i=6,0,-1 do
--   poke4(spritestart+(startrow*sheetwidth*8)+((i+1)*sheetwidth)+startcol*spritewide,peek4(spritestart+(startrow*sheetwidth*8)+(i*sheetwidth)+startcol*spritewide)) 
--  end
--  --now put bottom row on top!
--  poke4(spritestart+(startrow*sheetwidth*8)+startcol*spritewide,temp) 
-- end 

-- -------------------------------
-- -- print string s at x y with
-- -- color c and outline optional
-- function print6(_s,_x,_y,_c,_o)
-- end
-------------------------------
-- collision detection function;
-- returns true if two boxes overlap, false if they don't;
-- x1,y1 are the top-left coords of the first box, while w1,h1 are its width and height;
-- x2,y2,w2 & h2 are the same, but for the second box.
-- function checkcollision(x1,y1,w1,h1, x2,y2,w2,h2)
--   return x1 < x2+w2 and
--          x2 < x1+w1 and
--          y1 < y2+h2 and
--          y2 < y1+h1
-- end

-------------------------------
function printc(_str,_y,_c)
 len=#_str
 where=63-(len*2)
 if (where<0) where=0
 print(_str,where,_y,_c)
end
-------------------------------
function printo(str, x, y, c0, c1)
for xx = -1, 1 do
 for yy = -1, 1 do
 print(str, x+xx, y+yy, c1)
 end
end
print(str,x,y,c0)
end
-------------------------------
function printoc(_str, y, c0, c1)
 len=#_str
 where=63-(len*2)
 if (where<0) where=0
 for xx = -1, 1 do
  for yy = -1, 1 do
  print(_str, where+xx, y+yy, c1)
  end
 end
print(_str,where,y,c0)
end
-------------------------------
-- sprite print
-- _c = letter color
-- _c2 = line color
-- _c3 = background color of font
-- collapse all these sprite
-- printing routines into one
-- function if you want!
function sprint(_str,_x,_y,_c,_c2,_c3)
 local i, num
 palt(0,false) -- make sure black is solid
 if (_c != nil) pal(7,_c) -- instead of white, draw this
 if (_c2 != nil) pal(6,_c2) -- instead of light gray, draw this
 if (_c3 != nil) pal(5,_c3) -- instead of dark gray, draw this
 -- make color 5 and 6 transparent for font plus shadow on screen
  
 for i=1,#_str do
  num=asc(sub(_str,i,i))+160
  spr(num,(_x+i-1)*8,_y*8)
 end
 pal()
end
-------------------------------
-- sprite print centered on x
function sprintc(_str,_y,_c,_c2,_c3)
 local i, num
 _x=63-(flr(#_str*8)/2)
 palt(0,false) -- make sure black is solid
 if (_c != nil) pal(7,_c) -- instead of white, draw this
 if (_c2 != nil) pal(6,_c2) -- instead of light gray, draw this
 if (_c3 != nil) pal(5,_c3) -- instead of dark gray, draw this
 -- make color 5 and 6 transparent for font plus shadow on screen
  
 for i=1,#_str do
  num=asc(sub(_str,i,i))+32
  spr(num,_x+(i-1)*8,_y*8)
 end
 pal()
end
-------------------------------
-- sprite print at x,y pixel coords
function sprintxy(_str,_x,_y,_c)
 local i, num
 --palt(0,false) -- make sure black is solid
 if (_c != nil) pal(7,_c) -- instead of white, draw this
 --if (_c2 != nil) pal(6,_c2) -- instead of light gray, draw this
-- if (_c3 != nil) pal(5,_c3) -- instead of dark gray, draw this
 -- make color 5 and 6 transparent for font plus shadow on screen
  
 for i=1,#_str do
  num=asc(sub(_str,i,i))+32
  spr(num,_x+(i-1)*8,_y)
 end
 pal()
end
-------------------------------
-- double-sized sprite print at x,y pixel coords
function dsprintxy(_str,_x,_y,_c,_c2,_c3)
 local i, num,sx,sy
 palt(0,false) -- make sure black is solid
 if (_c != nil) pal(7,_c) -- instead of white, draw this
 if (_c2 != nil) pal(6,_c2) -- instead of light gray, draw this
 if (_c3 != nil) pal(5,_c3) -- instead of dark gray, draw this
 -- make color 5 and 6 transparent for font plus shadow on screen
 -- (btw you can use this technique
 -- just to draw sprites bigger)
 for i=1,#_str do
  num=asc(sub(_str,i,i))+160
  sy=flr(num/16)*8
  sx=(num%16)*8
  sspr(sx,sy,8,8,_x+(i-1)*16,_y,16,16)
 end
 pal()
end

__gfx__
bbbbbb00010bbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbb
bbbb101010101bbbbbb0aaaaaafaffffffffffffff9999999999494444442222222e2eededdddddddcdccccccccc1c1c1c11111111110bbbbbbbbbbbbbbbbbbb
bbb00001010101bbbbb0aaaaaaafaffffffffffffff9f99999999494444442222222e2eeddddddddddcdccccccc1c1c1c111111111110bbbbbbbbbbbbbbbbbbb
bb0010101111111bbbb0aaaaaaaafafaffffffffffff9f999999994944442422222e2eededdddddddcdccccccc1c1c111111111111110bbbbbbbbbbbbbbbbbbb
b000010101011101bbb0aaaaaaaaafafaffffffff66666f9666669946664422266666ed6666666dd666666666cc1c1111111111111110bbbbbbbbbbbbbbbbbbb
b000101011116111bbb0aaaaaaaaaafafaffffff6777776f677769667776642267776ee67777776c677777776c1111111111111111100bbbbbbbbbbbbbbbbbbb
0000010101167d110bb0aaaaaaaaaaafafafafff677777766777667777777626677776e6777777766777777761c111111111111111010bbbbbbbbbbbbbbbbbbb
000010101111d1111bb0aaaaaaaaaaaaaafafaff677777776777667777777666777776e677777777677777776c1111111111111010100bbbbbbbbbbbbbbbbbbb
00000101010111010bb0aaaaaaaaaaaaaaafafaf677767776777677776777766777777667777777767776666611111111111110101000bbbbbbbbbbbbbbbbbbb
00000010111111111bbb05a5aaaaaaaaaaaafafa67776677677767776666666677677766777667776777777761111111111110101000bbbbbbbbbbbbbbbbbbbb
00000101010101010bbb0a5a5a5aaaaaaaaaafaf67777777677767777677776777677766777767776777666661111111110101000000bbbbbbbbbbbbbbbbbbbb
b000001010101010bbbb0555a5a5aaaaaaaaaafa67777776677766777777776777767776777777776777777761111111101010000000bbbbbbbbbbbbbbbbbbbb
b000000001010101bbbb0555555a5a5aaaaaaaaf67777766677766777777767777767776777777766777777761111101010100000000bbbbbbbbbbbbbbbbbbbb
bb0000001010101bbbbb0555555555a5a5aaaaaa6777666f6777696777776677777667767777776c6777777761111010101000000000bbbbbbbbbbbbbbbbbbbb
bbb00000000000bbbbbb05555555555a5a5aaaaa66666fff666669966666266666666666666666cc6666666661010101010000000000bbbbbbbbbbbbbbbbbbbb
bbbb000000001bbbbbbb05555555555555a5a5aaaaaafafaffff9999494444222e2eeddddddcdccccc1c111110101010000000000000bbbbbbbbbbbbbbbbbbbb
bbbbb0000000bbbbbbbb055555555555555a5a5aaaaaafaffff9f9999444422222eededdddcdccccc111111101010100000000000000bbbbbbbbbbbbbbbbbbbb
bbb0005d667000bbbbbb055555555555555555a5aaaaaafaffff9999494444222eeeeddddddccccc1111111010100000000000000000bbbbbbbbbbbbbbbbbbbb
bb00005d6670101bbbbb0555555555555555555aaaaaaaafaff9f9999444422222eeddddddccccccc111110101000000000000000000bbbbbbbbbbbbbbbbbbbb
b000015d66710100bbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbb
0000105d667110101bbbbbb05555555555555555aaaaaaaffffff999944442222eeeedddddcccccc1111111000000000000000000bbbbbbbbbbbbbbbbbbbbbbb
00000105d51101000bbbbbb0555555557777777777777777777777777777777777777777777777777777777777777777000000000bbbbbbbbbbbbbbbbbbbbbbb
00001011111110101bbbbbb0555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7000000000bbbbbbbbbbbbbbbbbbbbbbb
b000010101010100bbbbbbb0555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7000000000bbbbbbbbbbbbbbbbbbbbbbb
bb0010101010101bbbbbbbb0555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7000000000bbbbbbbbbbbbbbbbbbbbbbb
bbb00000010000bbbbbbbbb0555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7000000000bbbbbbbbbbbbbbbbbbbbbbb
bbbbb0101010bbbbbbbbbbb0555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7000000000bbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbb0555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7000000000bbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbb0555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7000000000bbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbb0555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7000000000bbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbb0555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7000000000bbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbb0555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7000000000bbbbbbbbbbbbbbbbbbbbbbb
bbbbbb0000bbbbbbbbbbbbb0555555557bbbbbbbbbbbbbbbbbbbb44444bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7000000000bbbbbb00010bbbbbbbbbbbb
bbbb10101101bbbbbbbbbbb0555555557bbbbbbbbbbbbbbbbbb44aaaaafbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7000000000bbbb101010101bbbbbbbbbb
bbb0000100101bbbbbbbbbb0555555557bbbbbbbbbbbbbbbbb449aaaaaaf4bbbbbbbb44444bbbbbbbbbbbbbbbbbbbbb7000000000bbb00001010101bbbbbbbbb
bb001010111111bbbbbbbbb0555555557bbbbbbbbbbbbbbbb449aaaaaaaaf5bbbbb44aaaaafbbbbbbbbbbbbbbbbbbbb7000000000bb0010101111111bbbbbbbb
b00001010011101bbbbbbbb0555555557bbbbbbbbbbbbbbb444aaaaaaaaaafbbbb4a9aaaaaaf4bbbbbbbbbbbbbbbbbb7000000000b000010101011101bbbbbbb
b00010101116111bbbbbbbb0555555557bbbbbbbbbbbbbbb444aaaaaaaaaafbbb4a9aaaaaaaaf5bbbbbbbbbbbbbbbbb7000000000b000101011116111bbbbbbb
000001010167d110bbbbbbbb055555557bbbbbbbbbbbbbbb4449aaaaaaafafbb444aaaaaaaaaafbbbbbbbbbbbbbbbbb700000000b0000010101167d110bbbbbb
0000010100111010bbbbbbbb055555557bbbbbbbbbbbbbbbb4449aaaaffaafbb444aaaaaaaaaafbbbbbbbbbbbbbbbbb700000000b000010101111d1111bbbbbb
0000001011111111bbbbbbbb055555557bbbbbbbbbbbbbbbb49999aaaaaaa5bb4449aaaaaaafafbbbbbbbbbbbbbbbbb700000000b00000101010111010bbbbbb
0000010100101010bbbbbbbb055555557bbbbbbbbbbbbbbbbb49aaaaaaa45bbbb4449aaaaffaa5bbbbbbbbbbbbbbbbb700000000b00000010111111111bbbbbb
b00000101101010bbbbbbbbb055555557bbbbbbbbbbbbbbbbbb44aaaaa45bbbbbb4499aaaaa4bbbbbbbbbbbbbbbbbbb700000000b00000101010101010bbbbbb
b00000000010101bbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbb4444bbbbbbbbbbb4444444bbbbbbbbbbbbbbbbbbbb700000000bb000001010101010bbbbbbb
bb000000110101bbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bb000000001010101bbbbbbb
bbb0000000000bbbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bbb0000001010101bbbbbbbb
bbbb00000001bbbbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bbbb000000000007bbbbbbbb
bbbbbb0000bbbbbbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bbbbb00000000167000bbbbb
bbbbbb5d67bbbbbbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bbbbbbb000005d6670000bbb
bbbbbb5d67bbbbbbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bbbbbbbbb0005d66710101bb
bbbbb05d6700bbbbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbb24eeee5bbbbbbbbb555d551bbbbbbbbbbbbbbbbbbbb700000000bbbbbbbb000015dd5010100b
bbb0005d667000bbbbbbbbbb055555557bbbbbbbbbbbbbbbbbb4eeeeeeedbbbbbbb53cccccd5bbbbbbbbbbbbbbbbbbb700000000bbbbbbb00001015d11110101
bb00005dd670101bbbbbbbbb055555557bbbbbbbbbbbbbbbbb4eeeeeeeeedbbbbb5dcccccccd5bbbbbbbbbbbbbbbbbb700000000bbbbbbb00000101111101000
b000015dd6710100bbbbbbbb055555557bbbbbbbbbbbbbbbb24eeeeeeeeefdbbb5dcccccccccdbbbbbbbbbbbbbbbbbb700000000bbbbbbb00001011111110101
00001015d51110101bbbbbbb055555557bbbbbbbbbbbbbbbb44eeeeeeeeef6bb151cccccccccc5bbbbbbbbbbbbbbbbb700000000bbbbbbbb000010101010100b
00000101111101000bbbbbbb055555557bbbbbbbbbbbbbbbb444eeeeeeefefbb1d11cccccccccc5bbbbbbbbbbbbbbbb700000000bbbbbbbbb0010101010101bb
00001011111110101bbbbbbb055555557bbbbbbbbbbbbbbbb4444eeeee7feebb51d1dccccccccc5bbbbbbbbbbbbbbbb700000000bbbbbbbbbb00000010000bbb
b000010101010100bbbbbbbb055555557bbbbbbbbbbbbbbbb24e44eeefeeedbbd1ddd3cccccccc5bbbbbbbbbbbbbbbb700000000bbbbbbbbbbbb0101010bbbbb
bb0010101010101bbbbbbbbb055555557bbbbbbbbbbbbbbbbb44eeeeeeee4bbbf5ddccccccc665bbbbbbbbbbbbbbbbb700000000bbbbbbbbbbbbbbbbbbbbbbbb
bbb00000010000bbbbbbbbbb055555557bbbbbbbbbbbbbbbbbb24eeeeee4bbbbbd15dccccc67dbbbbbbbbbbbbbbbbbb700000000bbbbbbbbbbbbbbbbbbbbbbbb
bbbbb0101010bbbbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbb2244442bbbbbbbb55dcccccdbbbbbbbbbbbbbbbbbbb700000000bbbbbbbbbbbbb00010bbbbbb
bbbbbbbbbbbbbbbbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbdddddddbbbbbbbbbbbbbbbbbbbb700000000bbbbbbbbbbb101010101bbbb
bbbbbbbbbbbbbbbbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bbbbbbbbbb00001010101bbb
bbbbbbbbbbbbbbbbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bbbbbbbbb0010101111111bb
bbbbbb000010bbbbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bbbbbbbb000010101011101b
bbbb1010110101bbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bbbbbbbb000101011116111b
bbb000010010101bbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bbbbbbb0000010101167d110
bb00101011111111bbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bbbbbbb000010101111d1111
b0000101001011101bbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bbbbbbb00000101010111010
b0001010111116111bbbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbbbbbb00000010111111111
00000101001167d110bbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbbbbbb00000101010101010
0000101011111d1111bbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbbbbbbb000001010101010b
000001010010111010bbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbbbbbbb000000001010101b
000001010010111010bbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbbbbbbbb0000001010101bb
000000101111111111bbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbbbbbbbbb00000000000bbb
000001010010101010bbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbbbbbbb005000000001bbbb
b0000010110101010bbbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbbbbb00005d600000bbbbbb
b0000000001010101bbbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbbbb000055d667101bbbbbb
bb00000011010101bbbbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbbb000015d66670100bbbbb
bbb000000000000bbbbbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbb0000105d667110101bbbb
bbb00000000001bbbbbbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbb0000010d577101000bbbb
bb0000000000101bbbbbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbb00001011511110101bbbb
b000015d66710100bbbbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbbb000010101010100bbbbb
0000105d667110101bbbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbbbb0010101010101bbbbbb
00000105d51101000bbbbbbbb055555577777777777777777777777777777777777777777777777777777777777777770000000bbbbbbb00000010000bbbbbbb
00001011111110101bbbbbbbb0555555555555555555aaaaaaaffffff999944442222eeeedddddcccccc1111111000000000000bbbbbbbbb0101010bbbbbbbbb
b000010101010100bbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbb
bb0010101010101bbbbbbb055555555555555555555aaaaaaaaffffffff9994442222eedddddddcdcccccc11111100000000000000bbbbbbbbbbbbbbbbbbbbbb
bbb00000010000bbbbbbb05555555555555555555555aaaaaafaffffff9999944422eeeedddddddcdcccc1c11110100000000000000bbbbbbbbbbbbbbbbbbbbb
bbbbb0101010bbbbbbbbb0555555555555555555555aaaaaaaaffffff9f9994942222eedddddddcdcccccc111555d55510000000000bbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbb0555555555555555555555a5aaaaaafaffff9f9994942422eeeedddddddcdcccc1c115dccccc510000000000bbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbb055555555555555555555555aaaaaafaffffff999994442222eededddddcdcccccc111cccccccc510000000000bbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbb05555555555555555555555a5aaaaaafaffff9f9994942222eeeedddddddcdcccc1113ccccccccc55000000000bbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbb05555555555555555555555a5aaaaaafaffff9f999494222222eeeedddd24eeee50c113cccccccccc55000000000bbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbb05555555555555555555555a5aaaaaaaaffff9f999494242222eeeedddd4eeeeeeed0111ccccccccccd50000000000bbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbb0555555555555555555555a5a5aaaaaaffffff9f949424222222eeeedd4eeeeeeeeed0d11cccccccccc50000000000bbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbb0555555555555555555555a5a55aaaaafaffff9f999494222222eeeede24eeeeeeeeefd1dd3ccccccccd500000000000bbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbb0555555555555555555555a5a55aaaaaaaffff9f99949422222222eeeed44eeeeeeeeef61ddcccccccccd5000000000000bbbbbbbbbbbbbbb
bbbbbbbbbbbbbbb055555555555555555555a5a55aaaaaaaffffff9f949422222222eeeeee444eeeeeeefef515cccccc67d50000000000000bbbbbbbbbbbbbbb
bbbbbbbbbbbbbb0555555555555555555a5a5a555aaaaaafaffff9f94942422222222eeeed4444eeeee7fee55513cccc6d5000000000000000bbbbbbbbbbbbbb
bbbbbbbbbbbbbb055555555555555555a5a5a555aaaaaafaffff9f99942422222222e2eeee24e44eeefeeed11153cccdd50000000000000000bbbbbbbbbbbbbb
bbbbbbbbbbbbb05555555555555555555a55555aaaaaafaffff9f9994942222222222eeeeee44eeeeeeee41153ccccccd500000000000000000bbbbbbbbbbbbb
bbbbbbbbbbbb05555555555555555555a55555aaaaaaffffff9f999994242222222222eeeedd24eeeeee4115dccccccccd500000000000000000bbbbbbbbbbbb
bbbbbbbbbbbb0555555555555555555a5a555aaaaaaafffff9f999994242222222222eeeeeedd2244442c15dccccccccccd50000000000000000bbbbbbbbbbbb
bbbbbbbbbbb0555555555555555555a5a555aaaaaaffafff9f99999424222222222222eeeeee24eeed5cc151ccccccccccc510100000000000000bbbbbbbbbbb
bbbbbbbbbb05555555555555555a5a5a555aaaaaaffffff9f99999424222222222222e2eee44eeeeeee5c551dccccccccccd510100000000000000bbbbbbbbbb
bbbbbbbbbb0555555555555555a5a5a55aaaaaaaffffff9f9999999424222222222222eee44eeeeeeeee51d11ccccccccccc501010000000000000bbbbbbbbbb
bbbbbbbbb05555555555555a5a5a5a5aaaaaaaaffffffff9999999444222222222222e2ee44eeeeeeeeee51d1dcccccccccc5101010100000000000bbbbbbbbb
bbbbbbbbb0555555555555a5a5a5aaaaaaaafffffffff9999999944424222222222222ee44eeeeeeeeeefd1ddd3ccccccccc5110101010100000000bbbbbbbbb
bbbbbbbbb055555555555a5a5aaaaaaaaaafafffffff999999994942422222222222222e44eeeeeeeeeeff5ddcccccccc6651111110101010100000bbbbbbbbb
bbbbbbbbb055555555a5a5aaaaaaaaaaaffffffffff999999999944424222222222222e2444eeeeeeeefffd15dcccccc67d51111111110101010000bbbbbbbbb
bbbbbbbbb05a5a5a5a5a5aaaaaaaaaffffffffffff999999999944424222222222222222444eeeeeeef7e7d555dccccccd511111111111110101000bbbbbbbbb
bbbbbbbbb0a5a5a5a5aaaaaaaaffffffffffffff999999999994442422222222222222242444eeeee77e77dcccddddddd5111111111111111111100bbbbbbbbb
bbbbbbbb0a5aaaaaaaaaaafaffffffffffffff999999999999444442422222222222222f24ee4eeeffef76cccccccccc1c1111111111111111111110bbbbbbbb
bbbbbbbb0aaaaaaaafafafffffffff9ffff9999999999999949444242222222222222222e24eeeeeef776cdcccccccccc1c111111111111111111110bbbbbbbb
bbbbbbbb0aaaaafafaaafffffffff9f999999999999999494944424222222222222222222ee44eeef776cdcccccccccc1c1c11111111111111111110bbbbbbbb
bbbbbbbb0fafafafafafffffff9f9f999999999999999494944424242222222222222222e2eeedeee6dddcdcccccccccc1c1c1111111111111111110bbbbbbbb
bbbbbbbb0afafafffffffff9f9f9f99999999999999949444444424222222222222222222e2eeeeeddddddcdcccccccccccc1c1c1111111111111110bbbbbbbb
bbbbbbbb0fffffffffff9f9f9f999999999999999494944444442422222222222222222222e2eeeeddd5dddcdcccccccccccc1c1c111111111111110bbbbbbbb
bbbbbbb0fffffffffff9f9f9999999999999994949494444444242222222222222222222222e2eeeddddddddcccccccccccccc1c1c111111111111110bbbbbbb
bbbbbbb0fffff9ffff9f999999999999999494949494444444242422222222222222222222e2eeeeeddddddcdcccccccccccccc1c1c11111111111110bbbbbbb
bbbbbbb0fffffff9f9f99999999999994949494444444444444242222222222222222222222e2eeeeeddddddcdcccccccccccccccc1c1c11111111110bbbbbbb
bbbbbbb09f9f9f9f999999999999999494949444444444444424222222222222222222222222e2eeeedddddddcccccccccccccccccc1c1c1111111110bbbbbbb
bbbbbbb099f9f9999999999999994949494944444444444442422222222222222222222222222e2eeededdddcdcccccccccccccccccccc1c111111110bbbbbbb
bbbbbb099999999999999999999494949444444444444444242222222222222222222222222222e2eeededdddcdcccccccccccccccccccc1c111111110bbbbbb
bbbbbb0999999999999999994949494944444444444444424242222222222222222222222222222eeeeeddddddcdcccccccccccccccccccc1c11111110bbbbbb
bbbbbb05999999999994449494949494444444444444442424222222222222222222222222222222eeeeeddddddcccccccccccccccccccccc111111110bbbbbb
bbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbb
__label__
6666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666d
6cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1
6cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1
6ccccccddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddcccccc1
6cccccd111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111dccccc1
6ccccd11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111dcccc1
6cccd1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111dccc1
6ccd111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111dcc1
6ccd11111111111111111cccccc111cccccc111cccc111ccccc111111111111ccc111cccccc1111cccc1111ccc111ccccc111cccccc11111111111111111dcc1
6ccd11111111181111111cc111cc1111cc1111cc11cc1cc111cc1111111111cc1cc11cc111cc11cc11cc11cc1cc11cc11cc11cc111111111181111111111dcc1
6ccd1111111197f111111cc111cc1111cc111cc111111cc111cc111111111cc111cc1cc111cc1cc111111cc111cc1cc111cc1cc11111111197f111111111dcc1
6ccd1111111a777e11111cc111cc1111cc111cc111111cc111cc111111111cc111cc1cc11ccc1cc111111cc111cc1cc111cc1ccccc11111a777e11111111dcc1
6ccd11111111b7d111111cccccc11111cc111cc111111cc111cc111111111ccccccc1ccccc111cc111111ccccccc1cc111cc1cc111111111b7d111111111dcc1
6ccd111111111c1111111cc111111111cc1111cc11cc1cc111cc111111111cc111cc1cc11cc111cc11cc1cc111cc1cc11cc11cc1111111111c1111111111dcc1
6ccd11111111111111111cc1111111cccccc111cccc111ccccc1111111111cc111cc1cc111cc111cccc11cc111cc1ccccc111cccccc11111111111111111dcc1
6ccd111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111dcc1
6ccd111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111dcc1
6cccd1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111dccc1
6ccccd11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111dcccc1
6cccccd111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111dccccc1
6ccccccddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddcccccc1
6cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1
6cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111115
45454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454542
64444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444445
69999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999995
69999944444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444999995
69999400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050000000000000000000000000499995
69994000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000049995
69994000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000049995
69940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004995
69940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004995
69940000000000000000000000000000000000006000000000000000000000000000000000000000000000506000000000000000000000000000000000004995
69940000000000000000000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004995
69940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004995
69940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004995
69940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004995
69940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004995
69940000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000004995
699400000000000000000000000000000000000000000000aaaaaa000aaaaaa000aaaa000aaaaa00000000000000000000000000000000000000000000004995
69940000000000000000000000000000000000000000500077000770000770000770077077000770000000000000000000000000000000000000000000004995
699400000000000000000000000000000000000000000000aa000aa0000aa000aa000000aa000aa0000000000000000000000000000000000000000000004995
699400000000000000000000000000000000000000000000aa000aa0000aa000aa000000aa000aa0000000000000000000000000000000000000000000004995
69940000000000000000000000000000000000000000000099999900000990009900000099000990000000000000000000000000000000000000000000004995
69940000000000000000000000000000000000000000000099000000000990000990099099000990000000000000000000000000000000000000000000004995
699400000000000000000000000000000000000000000000aa0000000aaaaaa000aaaa000aaaaa00000000000000000000000000000000000000000000004995
69940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004995
699400000000000000000000000000000000000000aaa000aaaaaa0000aaaa0000aaa000aaaaa000aaaaaa000000000000000000000000000000000000004995
69940000000000000000000000000000000000000770770077000770077007700770770077007700770000000000000000000000000000000000000000004995
6994000000000000000000000000000000000000aa000aa0aa000aa0aa000000aa000aa0aa000aa0aa0000000000000000000000000000000000000000004995
6994000000000000000000000000000000000000aa000aa0aa00aaa0aa000000aa000aa0aa000aa0aaaaa0000000000000000000000000000000000000004995
69940000000000000000000000000000000000009999999099999000990000009999999099000990990000000000000000000000000000000000000000004995
69940000000000000000000000000000000000009900099099009900099009909900099099009900990005000000000000000000000000000000000000004995
6994000000000000000000000000000000000000aa000aa0aa000aa000aaaa00aa000aa0aaaaa000aaaaaa000000000000000000000000000000000000004995
69940000000000000000000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000004995
69940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004995
69940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050004995
69940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004995
69940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004995
69940000000000000000000000000000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000004995
69940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004995
69940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004995
69940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004995
69940000000000000aaa0a000a0000000aaa0aaa00aa0aaa0aa00aaa000000aa0aaa0a0a0a000aaa000000aa0aaa0aaa0aaa00aa00a000000000000000004995
69940000000000000a0a0a000a0000000a0a0a0a0a000a0a0a0a0a0000000a0000a00a0a0a000a0000000a000a0a0aaa0a000a0000a000000000000000004995
69940000000000000aaa0a000a0000000aaa0aa00a000aaa0a0a0aa00aaa0aaa00a00aaa0a000aa000000a000aaa0a0a0aa00aaa00a000000000000000004995
69940000000000000a0a0a000a0000000a0a0a0a0a000a0a0a0a0a000000000a00a0000a0a000a0000000a0a0a0a0a0a0a00000a000000000000000000004995
69940000000000000a0a0aaa0aaa00000a0a0a0a00aa0a0a0aaa0aaa00000aa000a00aaa0aaa0aaa00000aaa0a0a0a0a0aaa0aa000a000000000000000004995
69940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004995
69940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004995
69940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004995
69940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004995
69940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004995
69940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004995
69940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004995
69940000000000000000000000000000000000000000000000000000000000999900000000000000000000000000000000000000000000000000000000004995
6994000000000000000000000000000000000000000000000000000000000a7997a0000000000000000000000000000000000000000000000000000000004995
69940000000000000000000000000000000000000000000000000000000097099079000000000000000000000000000000000000000000000000000000004995
69940000000000000000000000000000000000000000000000000000000099999999000000000000000000000000000000000000000000000000000000004995
69940000000000000000000000000000000000000000000000000000000099911999000000000000000000000000000000000000000000000000000000004995
69940000000000000000000000000000000000000000000000000000000099911999000000000600000000000000000000000000000000000000000000004995
69940000000000000000000000000000000000000000000000000000000099999999000000000000000000000000000000000000000000000000000000004995
69940000000000000000000000000000000000000000000000000000000090909090000000000000000000000000000000000000000000000000000000004995
69940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004995
69940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000504995
69940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004995
69940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004995
69940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004995
69940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004995
69940000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000004995
69940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004995
69940000000000000000000000000000000444440004444400000044400440444000000440444044404440044000000000000000000000000000000000004995
69940000000000000000000000000000004440044044004440000040004040404000004000404044404000400000000000000000000000000000000000004995
69940000000000000000000000000000004400044044000440000044004040440000004000444040404400444000000000000000000000000000000000004995
69940000000000000000000000000005004440044044004440000040004040404000004040404040404000004000000000000000000000000000000000004995
69940000000000000000000000000000000444440004444400000040004400404000004440404040404440440000000000000000000000000000000000004995
69940000000000000000000060000000000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000004995
69940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000000000004995
69940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050000000004995
69940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004995
69940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000000000004995
69940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004995
69940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004995
69940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004995
69994000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000049995
69994000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000049995
69999400000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000499995
69999944444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444999995
69999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999995
69999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999995
45555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555551
65555555555555555555555555aaaa555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555d5
7666666666666666666666666a999946666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666610
76cccccccccccccccccccccca9999944cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc10
76cccccccccccccccccccccc99999444cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc10
76cccccccccccccccccccccc94994444cccccccccccccccccc7777ccccccccccccaaaaccccccccccccccccccccccccccccaaaacccccccccccccccccccccccc10
76ccccccccccccccccccccccc444444cccccccccccccccccc7dd665cccccccccca44995cccccccccccccccccccccccccca33bb5ccccccccccccccccccccccc10
6ccccccccccccccccccccccccc4444cccccccccccccccccc7d666665cccccccca4999995cccccccccccccccccccccccca3bbbbb5ccccccccccccccccccccccc1
6ccccccccccccccccccccccccc6555ccccccccccccccccccd7d66651cccccccc4a499952cccccccccccccccccccccccc3a3bbb51ccccccccccccccccccccccc1
cccccccccccccccccccccccc11766511cccccccccccccccccd55551cccccccccc455552cccccccccccccccccccccccccc355551ccccccccccccccccccccccccc
ccccccccccccccccccccccc1115662111cccccccccccccccccdd11cccccccccccc4422cccccccccccccccccccccccccccc3311cccccccccccccccccccccccccc
cccccccccccccccccccccc111115511111cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccc1111111111ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccc11111111cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111

__gff__
0000010101010101010101010101010100000101010101010101010101010101000001010101010101010101010101010000010101010101010101010101010100000101010100000000010101000000000001010101000000000101010000000000010101010000000001010100000000000101010100000000010101000000
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
000100002e1502e1502f1502f1502f150351503715000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
000200002e5502e5503555035550166003a5503a55037500345003350034500385000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000200001c620385503455031550305502e5502d5501d6201d6201d6001d600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000006500065000650006551305014050140501405014050140501405013050110500e0500b0500905008050070500605005050050500505006050070500105001030010230000000000000000000000000
000400000024000231062002100000240002310022100213190001a00023000280000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300002a750267502a7500070032750377003970039700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
0004000036630236701f6711c6511b6511b6511a6511a6511a630176310e631066310463102631016310063100631006110061100611006110061100611006110061101600006000060000300003000030000300
000200000b3240d331103411c341233412634127341293412c3312e32500300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
000700180062307623000000762300623000000000000623076230000007623006230000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050000307342b751237511d75117751127510d75108751037310271501713007050c7000a700077000670004700027000170000700007000070000700007000070000700017000070000700007000070000700
000200002f3402f3412f33136334363413634136331363313632136321363213631136315383003f3000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
00010000312502b250252502025019250122500e2500e6300e6300e6351520010200072000420000200002000d20009200082000820000200002000120026100121001e100061000d10019100251000c10024100
0006000019150201501c150231502313519130201301c130231302312519120201201c120231202311519110201101c1102311023115001000010000100001000010000100001000010000100001000010000100
000900000b6500b6500b6531c6001c6501c650156300e630096300763005610036100161001615000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400001c6301c630232541c35120353173501b3501935422230246002460025600266002660027600156000f6000b6000760006600056000460004600046000020000200002000020000200002000020000200
0003000028630286301e6501a650186501664014640106400f6400c630096300663005630026100161001610016102750020500235002c5002e50022500295002e500325001f5002a5002d500265002a5001c500
000300000863111631206003365032651306512a651226511a651136410d641086410463101631006110061500000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000017630106300e6500e6301063213652186521e6522a6523663236632306323062221622126220661200612006120161200612006150060000600006000060000600006000060000600006000060000600
010c00201125411255052550000000000112541125505255000000000011254112550525500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100000705005050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200000205004050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300000005002050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010f000005135051050c00005135091351c0150c1351d0150a1351501516015021350713500000051350000003135031350013500000021351b015031351a0150513504135000000713505135037153c7001b725
010f00000c03300000300152401524615200150c013210150c003190151a01500000246153c70029515295150c0332e5052e5150c60524615225150000022515297172b71529014297152461535015295151d015
010f000007135061350000009135071351f711000000510505135041350000007135051351c0151d0150313503135021350000005135031350a1050a135000000113502135031350413505135000000a13500000
010f00000c033225152e5153a515246152b7070a145350150c003290153200529005246152501526015220150c0331e0251f0252700524615225051a0152250522015225152201522515246150a7110a0001d005
011400000c0330253502525020450e6150252502045025250c0330253502525020450e6150252502045025250c0330252502045025350e6150204502535025250c0330253502525020450e615025250204502525
011400001051512515150151a5151051512515150151a5151051512515150151a5151051512515150151a5151051512515170151c5151051512515170151c5151051512515160151c5151051512515160151c515
011400001c5151e5151a515150151c5151e5151a015155151c5151e5151a515150151c5151e5151a015155151c5151e51517015230151c5151e51517015230151c5151e515165151c0151c5151e515160151c515
011400000c0330653506525060450e6150652506045065250c0330653506525060450e6150652506045065250c0330952509045095350e6150904509535095250c0330953509525090450e615095250904509525
0114000020515215151c5151901520515215151c0151951520515215151c5151901520515215151c0151951520515215151c0151901520515215151c01525515285152651525515210151c5151a5151901515515
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
018800000074400730007320073200730007300073200732007300073200730007320073000732007320073200732007300073000730007320073000730007300073200732007300073000732007300073200732
01640020070140801107011060110701108011070110601100013080120701106511070110801707012060110c013080120701106011050110801008017005350053408010070110601100535080170701106011
018800000073000730007320073200730007300073200732007300073200730007320073000732007320073200732007300073000730007320073000730007300073200732007300073000732007300073200732
0164002006510075110851707512060110c0130801207011060110501108017070120801107011060110701108011075110651100523080120701108017005350053408012070110601100535080170701106511
010a000024045270352d02523045260352c02522045250352b02522035250352b02522035250252b01522725257252b71522715257152b71522715257152b7151700017000170001700017000130000c00000000
010a000021705247052a7052072523715297151f72522715287151f71522715287151f71522715287151f71522715287151f71522715287151f70522705287051770017700177001770017700137000c70000700
010c00000f51014510185101b510205102451011510165101a5101d510225102651013510185101c5101f5102451028510285102851028510285102851028515240042450225504255052650426502265050e500
010c000014730187301b730207302473027730167301a7301d730227302673029730187301c7301f73024730287302b730307403073030730307303072030715247042470225704257052670426702267050e700
011200000843508435122150043530615014351221502435034351221508435084353061512215054250341508435084350043501435306150243512215034351221512215084350843530615122151221524615
011200000c033242352323524235202351d2352a5111b1350c0331b1351d1351b135201351d135171350c0330c0332423523235202351d2351b235202352a5110c03326125271162c11523135201351d13512215
0112000001435014352a5110543530615064352a5110743508435115152a5110d43530615014352a511084150d4350d4352a5110543530615064352a5110743508435014352a5110143530615115152a52124615
011200000c033115152823529235282352923511515292350c0332823529216282252923511515115150c0330c033115151c1351d1351c1351d135115151d1350c03323135115152213523116221352013522135
0112000001435014352a5110543530615064352a5110743508435115152a5110d435306150143502435034350443513135141350743516135171350a435191351a1350d4351c1351d1351c1351d1352a5011e131
011200000c033115152823529235282352923511515292350c0332823529216282252923511515115150c0330c033192351a235246151c2351d2350c0331f235202350c033222352323522235232352a50130011
011600000042500415094250a4250042500415094250a42500425094253f2050a42508425094250a425074250c4250a42503425004150c4250a42503425004150c42500415186150042502425024250342504425
011600000c0330c4130f54510545186150c0330f545105450c0330f5450c41310545115450f545105450c0230c0330c4131554516545186150c03315545165450c0330c5450f4130f4130e5450e5450f54510545
0116000005425054150e4250f42505425054150e4250f425054250e4253f2050f4250d4250e4250f4250c4250a4250a42513425144150a4250a42513425144150a42509415086150741007410074120441101411
011600000c0330c4131454515545186150c03314545155450c033145450c413155451654514545155450c0230c0330c413195451a545186150c033195451a5451a520195201852017522175220c033186150c033
010b00200c03324510245102451024512245122751127510186151841516215184150c0031841516215134150c033114151321516415182151b4151d215224151861524415222151e4151d2151c4151b21518415
010200002067021670316602f65031650336503365033650386503f6503f650326502f6502f650006002f6502e6502d650006002b650296502760024650216001e65019600116500a60000630066000161000010
010200000e6510c6530a6520b653056530000000000000000e6510c6530a652000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000013535000002b5070000037535000001f507000002b5350000000000000001f53500000000000000013505000002b5070000037535000001f507000002b5350000000000000001f535000000000000000
011000000062200622006220062202622026220262202622006220062200622006220262202622026220262200622006220062200622026220262202622026220062200622006220062202622026220262202622
__music__
00 16174344
00 16174344
01 16174344
00 16174344
00 18194344
02 18194344
00 1a424344
01 1a1b4344
00 1a1b4344
00 1a1c4344
00 1a1c4344
02 1d1e4344
01 1f204344
00 1f214344
00 1f204344
00 1f214344
00 22234344
02 1f244344
01 25264344
00 25264344
02 27284344
00 292a4344
03 2b2c4344
04 2d2e4344
04 2f304344
01 31324344
00 31324344
00 33344344
02 35364344
01 37384344
00 393a4344
00 373b4344
02 393b4344
03 3e424344
