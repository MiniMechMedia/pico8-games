pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--{GAMENAME}
--{AUTHORINFO} 

e=124::_::cls(14)
srand()
for y=-e,e,6 do 
    for x=e,-6,-6 do 
        z=y+x
        -- d=(x-64)^2+(z-64)^2 
        d = 0
        a=rnd{0,.25}*1+mid(,sin(-t()/50),0)
        u,v=cos(a)*5,sin(a)*5
        for q=0,0 do 
            line(x-q,z+q,x+u-q,z+v+q,8)
            -- line(x,z-q,x+u,z+v-q,13-(q\2)*6)
        end 
    end 
end 
flip()
goto _
-- poke(0x5f2c, 3)



-- rooms = {}
-- corridors = {}
-- for i = 0, 32*32-1 do
--     rooms[i] = i
--     corridors[2*i] = true
--     corridors[2*i+1] = true
-- end

-- ordererdindex = 1
-- shuffled = {}
-- for i = 0, 2*32*32-1 do
--     shuffled[i]=i
-- end
-- for i = 2*32*32-1, 2, -1 do
--     local j = flr(rnd(i))
--     shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
-- end

-- ::_::
-- cls()
-- -- This is the corridor of interest
-- -- shuffled[index]
-- -- if index is even, it connects 2 horizontally connected rooms TODO ponder wraparound
-- for k = 1,10 do
-- index = shuffled[ordererdindex]
-- if index != nil then
-- if index%2 == 0 then
--     room1 = index\2
--     room2 = index\2 + 1
-- else
-- -- otherwise it connects 2 vertically connected rooms
--     room1 = index\2
--     room2 = index\2 + 32
-- end
-- ordererdindex += 1
-- if rooms[room1] != rooms[room2] then
--     -- Tear down this wall!
--     oldroot = rooms[room1]
--     corridors[index] = false

--     -- rooms[room1] = rooms[room2]
--     for i = 0, 32*32-1 do
--         if rooms[i] == oldroot then
--             rooms[i] = rooms[room2]
--         end
--     end
-- end
-- end
-- end

-- for i = 0,32*32-1 do
--     x,y=i%32,i\32
--     pset(x*2,y*2,7)
--     if not corridors[2*i] then
--         pset(x*2+1,y*2, 7)
--     end
--     if not corridors[2*i+1] then
--         pset(x*2,y*2+1, 7)
--     end
-- end
-- flip()
-- goto _

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__meta:cart_info_start__
cart_type: tweet
# Embed: 750 x 680
game_name: Tweet Template
# Leave blank to use game-name
game_slug: ''
jam_info: []
tagline: XXXX
time_left: ''
develop_time: ''
description: |
  
controls: []
hints: ''
acknowledgements: ''
to_do: []
version: 0.1.0
img_alt: XXX
about_extra: ''
number_players: [0]
__meta:cart_info_end__
