pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--queen anne's lace tweet        v0.1.0
--mini mech media


-- We will draw a fractal that looks like Queen Ann's Lace.
-- We will create the illusion of an infinite zoom.

function flower_(x,y,angle_,scale_,depth_)
-- Base case: Draw the flower. It's simply a white pixel and gray pixel for shading
if(depth_<1)pset(x*globalscale_,y*globalscale_,6)pset(x*globalscale_+1,y*globalscale_,7)return
-- Otherwise, draw 7 copies
for i=-3,3do
childangle_b=angle_+i/24
-- Calculates the endpoint of the stem
u,v=x+scale_*cos(childangle_b),y+scale_*sin(childangle_b)
-- Draw the stem. Draw a bright green line and a dark green line offset by 1 pixel for shading
line(x*globalscale_,y*globalscale_,u*globalscale_,v*globalscale_,3)--[[
]]line(x*globalscale_+1,y*globalscale_,u*globalscale_+1,v*globalscale_,11)--[[
-- Recursively draw the rest of the flower at the endpoint
]]flower_(u,v,childangle_b,scale_/6,depth_-1,i+4)--[[
]]end
end
-- Drawing will be scaled by this amount
globalscale_=1
-- Allow 0,0 to be drawn at screen coordinates (64, 50)
camera(-64,-50)--[[
]]::_::--[[
]]cls(12)--[[
]]flower_(0,179.9,.25,150,4,1)--[[
-- Zoom in 4% every frame
]]globalscale_*=1.04
-- Reset scale at a zoom factor of 6 to cleanly loop
if(globalscale_>6)globalscale_=1
flip()
goto _


__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc677777777ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccc6777777c6773b3bb3b7c6777777cccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc677b3b3b7777b3b3bb3b7777b3b3b77cccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccc6777bb3b3bb67b3b3bbbb3b7bbb3b3bb777cccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccc67bc3bbbb3bcc3b3bbbbbbccc3bbbb3b3b7cccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccc6777777b3b3bbbbbcccc3bbbbbbcccc3bbbbb3b3b777777cccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccc6777bb3b73bbb3bbbbcccccc3bbbcccccc3bbbbbbb67b3bb777cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccc677b3bb3bccc3bbbbbcccccccc3bccccccc3bbbbbccc3b3bb3b77ccccccccccccccccccccccccccccccccccccc
777777ccccccccccccccccccccccccccccccc677b3bbbbccccc3bbbbcccccccc3bcccccccc3bbbccccc3bbb3bb77ccccccccccccccccccccccccccccccc67777
7bb3b777c6777777ccccccccccccccccccccc63b3bbbbbccccccc3bccccccccc3bcccccccc3bccccccc3bbbbb3b7ccccccccccccccccccccc6777777c6777b3b
3bb3b3b7777b3bb777cccccccccccccccccc6773b3bbbbccccccc3bccccccccc3bcccccccc3bccccccc3bb3b3b677cccccccccccccccccc67773b3b7777b3b3b
3bbb3b3b7b3b3bb3b77cccccccccccccccc677bb3bbbbbcccccccc3bcccccccc3bccccccc3bcccccccc3bbbbb33b77cccccccccccccccc677bb3b3b3b7b3b3bb
bbbb3bbcc3b3bbb3bb77ccccccccccc67777b7c3bbbbbccccccccc3bcccccccc3bccccccc3bccccccccc3bbbbbc67b7777ccccccccccc67bb3bbbb3bcc3bb3bb
bbbbbbccc3b3bbbbbc3b777777cccc677bb3bccccc3bbccccccccc3bcccccccc3bccccccc3bccccccccc3bbccccc3b3bb77cccc67777777c3bbbbb3bccc3bbbb
bbbbbccccc3bbb3bc3bb7bb3b77cc67bc3b3bccccccc3bcccccccc3bcccccccc3bccccccc3bcccccccc3bccccccc3b3bb3b7c6777b3bb7bcc3bbbbbccccc3bbb
3bbbccccccc3bbbbbbcc3bb3b3b77773b3bbbccccccc3bccccccccc3bccccccc3bcccccc3bccccccccc3bccccccc3bbb3b67777b3b3bbc3bb3bbbbccccccc3bb
c3bcccccccc3bbbbcccc3bbb3b3b77bc3b3bbcccccccc3bcccccccc3bccccccc3bcccccc3bcccccccc3bcccccccc3bbbbc3b77b3b3bbbccc3bbbbbcccccccc3b
c3bccccccccc3bcccccc3bbb3bb3b7bbb3bbbcccccccc3bcccccccc3bccccccc3bcccccc3bcccccccc3bcccccccc3bbb3bbb7b3bb3bbbccccc3bbccccccccc3b
c3bccccccccc3bccccccc3bbbbc3b773bbbbbccccccccc3bcccccccc3bcccccc3bcccccc3bccccccc3bccccccccc3bbbbb667bc3bbbbccccccc3bccccccccc3b
c3bcccccccc3bcccccccc3bbb3bb3b7bbbbbbcccccccccc3bccccccc3bcccccc3bccccc3bccccccc3bcccccccccc3bbbbb3b77bb3bbbcccccccc3bcccccccc3b
c3bcccccccc3bcccccccc3bbbbbb667ccccc3bccccccccc3bccccccc3bcccccc3bccccc3bccccccc3bccccccccc3bccccc6673bbbbbbcccccccc3bcccccccc3b
c3bcccccccc3bcccccccc3bbccccccccccccc3bccccccccc3bcccccc3bcccccc3bccccc3bcccccc3bccccccccc3bccccccccccccc3bbcccccccc3bcccccccc3b
c3bcccccccc3bccccccc3bcccccccccccccccc3bccccccccc3bcccccc3bccccc3bccccc3bcccccc3bcccccccc3bcccccccccccccccc3bccccccc3bcccccccc3b
c3bccccccc3bcccccccc3bccccccccccccccccc3bcccccccc3bcccccc3bccccc3bcccc3bcccccc3bcccccccc3bccccccccccccccccc3bcccccccc3bccccccc3b
c3bccccccc3bccccccc3bccccccccccccccccccc3bcccccccc3bccccc3bccccc3bcccc3bcccccc3bccccccc3bccccccccccccccccccc3bccccccc3bccccccc3b
c3bccccccc3bccccccc3bcccccccccccccccccccc3bccccccc3bcccccc3bcccc3bcccc3bccccc3bccccccc3bcccccccccccccccccccc3bccccccc3bccccccc3b
c3bcccccc3bccccccc3bcccccccccccccccccccccc3bccccccc3bccccc3bcccc3bcccc3bcccc3bccccccc3bcccccccccccccccccccccc3bccccccc3bcccccc3b
c3bcccccc3bccccccc3bccccccccccccccccccccccc3bccccccc3bcccc3bcccc3bccc3bccccc3bcccccc3bccccccccccccccccccccccc3bccccccc3bcccccc3b
c3bcccccc3bcccccc3bccccccccccccccccccccccccc3bcccccc3bcccc3bcccc3bccc3bcccc3bcccccc3bccccccccccccccccccccccccc3bcccccc3bcccccc3b
c3bcccccc3bccccc3bccccccccccccccccccccccccccc3bcccccc3bcccc3bccc3bccc3bcccc3bccccc3bccccccccccccccccccccccccccc3bccccc3bcccccc3b
c3bccccc3bcccccc3bcccccccccccccccccccccccccccc3bccccc3bcccc3bccc3bcc3bcccc3bccccc3bcccccccccccccccccccccccccccc3bcccccc3bccccc3b
c3bccccc3bccccc3bcccccccccccccccccccccccccccccc3bccccc3bccc3bccc3bcc3bccc3bccccc3bcccccccccccccccccccccccccccccc3bccccc3bccccc3b
c3bccccc3bccccc3bccccccccccccccccccccccccccccccc3bccccc3bccc3bcc3bcc3bccc3bcccc3bccccccccccccccccccccccccccccccc3bccccc3bccccc3b
c3bcccc3bccccc3bccccccccccccccccccccccccccccccccc3bbccc3bccc3bcc3bcc3bcc3bcccc3bccccccccccccccccccccccccccccccccc3bccccc3bcccc3b
c3bcccc3bccccc3bccccccccccccccccccccccccccccccccccc3bccc3bcc3bcc3bc3bccc3bccc3bcccccccccccccccccccccccccccccccccc3bccccc3bcccc3b
c3bcccc3bcccc3bccccccccccccccccccccccccccccccccccccc3bccc3bcc3bc3bc3bcc3bccc3bcccccccccccccccccccccccccccccccccccc3bcccc3bcccc3b
c3bcccc3bccc3bccccccccccccccccccccccccccccccccccccccc3bcc3bcc3bc3bc3bc3bccc3bcccccccccccccccccccccccccccccccccccccc3bccc3bcccc3b
c3bccc3bcccc3bcccccccccccccccccccccccccccccccccccccccc3bcc3bc3bc3bc3bc3bcc3bccccccccccccccccccccccccccccccccccccccc3bcccc3bccc3b
c3bccc3bccc3bcccccccccccccccccccccccccccccccccccccccccc3bc3bc3bc3b3bc3bcc3bccccccccccccccccccccccccccccccccccccccccc3bccc3bccc3b
c3bccc3bccc3bccccccccccccccccccccccccccccccccccccccccccc3bc3bc3b3b3bc3bc3bcccccccccccccccccccccccccccccccccccccccccc3bccc3bccc3b
c3bccc3bcc3bccccccccccccccccccccccccccccccccccccccccccccc3bc3b3b3b3b3bc3bcccccccccccccccccccccccccccccccccccccccccccc3bcc3bccc3b
c3bcc3bccc3bcccccccccccccccccccccccccccccccccccccccccccccc3b3b3b3b3b3b3bccccccccccccccccccccccccccccccccccccccccccccc3bccc3bcc3b
c3bcc3bcc3bcccccccccccccccccccccccccccccccccccccccccccccccc3b3b3bbb3b3bccccccccccccccccccccccccccccccccccccccccccccccc3bcc3bcc3b
c3bcc3bc3bcccccccccccccccccccccccccccccccccccccccccccccccccc3b3bbbbb3bccccccccccccccccccccccccccccccccccccccccccccccccc3bc3bcc3b
c3bc3bcc3bccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbbbbbcccccccccccccccccccccccccccccccccccccccccccccccccc3bcc3bc3b
c3bc3bc3bccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbbbcccccccccccccccccccccccccccccccccccccccccccccccccccc3bc3bc3b
c3bc3bc3bcccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbccccccccccccccccccccccccccccccccccccccccccccccccccccc3bc3bc3b
b3bc3b3bcccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bccccccccccccccccccccccccccccccccccccccccccccccccccccccc3b3bc3b
b3b3bc3bcccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bc3b3b
b3b3b3bccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bcccccccccccccccccccccccccccccccccccccccccccccccccccccccc3b3b3b
b3b3bbcccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bb3b
3bbb3bcccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3b3bb
bbbbbccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bcccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbb
bbbbbccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bcccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbb
bbbbcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bb
bbbbcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bb
c3bccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3b
c3bccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3b
cc3bcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bc
cc3bcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bc
cc3bcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bc
cc3bcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bc
ccc3bccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bcccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bcc
ccc3bccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bcccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bcc
ccc3bccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bcccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bcc
ccc3bccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bcccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bcc
cccc3bcccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bccc
cccc3bcccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bccc
cccc3bcccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bccc
ccccc3bccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bccc
ccccc3bccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bcccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bcccc
ccccc3bccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bcccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bcccc
ccccc3bccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bcccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bcccc
cccccc3bcccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bccccc
cccccc3bcccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bccccc
cccccc3bcccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bccccc
cccccc3bcccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bccccc
ccccccc3bccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bcccccccccccccccccccccccccccccccccccccccccccccccccccccc3bcccccc

__meta:cart_info_start__
cart_type: tweet
# Embed: 750 x 680
game_name: Queen Anne's Lace Tweet
# Leave blank to use game-name
game_slug: 'queen-annes-lace-tweet'
jam_info: []
tagline: Umbels for days!
time_left: ''
develop_time: ''
description: |
  > If you look closely, you'll see that Queen Anne's lace is 
  composed of a cluster of flowers. And if you look even more
  closely, you'll see that the cluster is composed of a cluster.
  And if you look even more closely...

  A tweet cart that does an infinite zoom on a fractal flower
  that looks like [Queen Anne's Lace](https://en.wikipedia.org/wiki/Queen_Anne%27s_lace)
controls: []
hints: ''
acknowledgements: ''
to_do: []
version: 0.1.0
img_alt: A fractal structure that looks like Queen Anne's Lace
about_extra: ''
number_players: [0]
__meta:cart_info_end__