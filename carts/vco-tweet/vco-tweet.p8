pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--vco tweet                      v0.1.0
--mini mech media

-- We will be drawing a Very Compelling Object,
-- also known by the name Toroflux.
-- The collapsed state is shaped like a ring and
-- the expanded state is shaped like a torus.
-- We will be creating an animation where the object
-- repeatedly expands and collapses and rotates.
___c=cos
___s=sin
::_::
cls()
line()
-- A parameter used for a number of use cases
a=t()/9
-- Controls the progression of the expansion
-- and collapse. Smoothly oscillates between
-- 0 and 90 degrees (in PICO-8 an angle of 1/4==90 deg)
phase_=___s(a/1.3)^2/4
-- A torus can be formed as a surface of revolution by
-- sweeping one circle (called the minor circle) 
-- around another circle (called the major circle).
-- A standard parametization of a torus is
-- x = (R+r*cos(theta))cos(phi)
-- y = (R+r*cos(theta))sin(phi)
-- z = r*sin(theta)
-- Where R is the major radius, r is the minor radius,
-- phi is the angle around the major circle, and theta
-- is the angle around the minor circle.
-- We will be drawing a one dimensional curve along the
-- surface of the torus. 
for phi_i=0,200do
-- phi varies from 0 to 1 (remember, 1 = 360 deg in PICO-8)
phi_i/=200
-- theta from 0 to 1 means we are wrapping around the minor
-- circle. By multiplying by 13, we will wrap around the minor
-- circle 13 times by the time we traverse around the major
-- circle.
__theta=phi_i*13
-- We will be varying the major radius from 0 to 0.8
-- The minor radius will implicitly be 1
-- Even when the major radius is maximized, it is still
-- smaller than the minor radius, creating a self-intersecting
-- spindle torus.
-- When the major radius is minimized, the torus would
-- degenerate into a sphere. But because of a rotation we
-- apply later on, it will create a circle laying flat
-- in the plane.
__R=(1+___c(phase_*2))/2.5
-- This is neither the major nor minor radius, but is
-- the effective radius for a point on the torus
radius_=__R+___c(__theta)
-- u,v is a unit vector that when multiplied by the major
-- radius, coincides with the center of the minor circle.
-- Add a*4 to make the figure spin around the major axis.
u=___c(phi_i+a*4)
v=___s(phi_i+a*4)
z=___s(__theta)
-- So (Ru,Rv,z) is a point on the surface of the torus.
-- We rotate that point around the (u,v,0) axis by an
-- angle of phase. This makes it so the line goes from
-- looping around the surface of the torus (expanded state)
-- to flattening into a plane (collapsed state). The
x=radius_*u+z*v*___s(phase_)
y=radius_*v-z*u*___s(phase_)
-- Rotate around the y-axis by an angle of `a`
-- phi*5.9+8 is the color, which will go from 8 to 13 as we
-- spiral around, producing a rainbow effect.
line(25*(x*___c(a)-z*___c(phase_)*___s(a))+64,25*y+64,phi_i*5.9+8)
end
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000bbbbbb000ccccccccccc00000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000bbb000000cccbb000000000cc000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000bbb000000ccc00000b0000000000c00000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000bb0000000cc000000000bb000000000cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000b00000000c0000000000000b0000000000cc0000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000b00000000c000000000000000b00000000000c000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000b00000000c00000000000000000bb0000000000c00000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000b00000000c00000000000000000000b000000000c00000000000000000000000000000000000000000000
000000000000000000000000000000000000000000b00000000c0000000000000000000000b000000000c0000000000000000000000000000000000000000000
00000000000000000000000000000000000000000b00000000c000000000000000000000000b00cccccc0c000000000000000000000000000000000000000000
00000000000000000000000000000000000000000b00000bbcb000000000000000000000cccccc000000ccc00000000000000000000000000000000000000000
00000000000000000000000000000000000000000b0bbbb00c0bbbbb000000000000cccc0000b000000000ccc000000000000000000000000000000000000000
0000000000000000000000000000000000000000bbb00000c0000000bbbb00000ccc000000000b000000000c0cc0000000000000000000000000000000000000
00000000000000000000000000000000000000bbb0000000c00000000000bb0cc0000000000000b00000000c000c000000000000000000000000000000000000
0000000000000000000000000000000000000b00b000000c00000000000000cb00000000000000b00000000c000c000000000000000000000000000000000000
00000000000000000000000000000000000bb000b000000c000000000000cc00bb0000000000000b0000000c0000c00000000000000000000000000000000000
0000000000000000000000000000000000b0000b0000000c00000000000c000000bb00000000000b0000000c00000c0000000000000000000000000000000000
0000000000000000000000000000000000b0000b000000c00000000000c000000000b00000000000b000000c00000c0000000000000000000000000000000000
000000000000000000000000000000000b00000b000000c000000000cc00000000000b0000000000b0000000c00000c000000000000000000000000000000000
000000000000000000000000000000000b00000b00000c000000000c00000000000000b000000000b0000000c00000c000000000000000000000000000000000
000000000000000000000000000000000b00000b00000c00000000c0000000000000000b000000000b000000c00000c000000000000000000000000000000000
00000000000000000000000000000000b000000b00000b00000000c00000000000000000b00000000b000000c00000c000000000000000000000000000000000
00000000000000000000000000000000b000000b00000b0000000c0000000000000000000b0000000b000000c00000c000000000000000000000000000000000
00000000000000000000000000000000b0000000b0000b0000000c00000000000000000000b0000000b00000c00000c000000000000000000000000000000000
000000000000000000000000000000000b000000b0000b000000c0000000000000000000000b000000b00000c00000c000000000000000000000000000000000
000000000000000000000000000000000b000000b0000b00000c00000000000000000000000b000000b0000c000000c000000000000000000000000000000000
000000000000000000000000000000000b000000b0000b00000c00000000000000000000000cccccccccccdd000000c000000000000000000000000000000000
000000000000000000000000000000000b000000b0000b0000c0000000000000000000ccccc0b00000b0000cdddd0c0000000000000000000000000000000000
0000000000000000000000000000000000b00000baaaabaaaacaaaaaa000000000cccc0000000b0000b0000c0000ddd000000000000000000000000000000000
0000000000000000000000000000000000baaaaaab000b0000c000000aaa000ccc00000000000b0000b000c00000c00dd0000000000000000000000000000000
00000000000000000000000000000000aaab00000b000b000c0000000000ccc000000000000000b00b0000c00000c0000dd00000000000000000000000000000
000000000000000000000000000000aa000b000000b00b000c00000000cc000aaa000000000000b00b0000c0000c0000000d0000000000000000000000000000
00000000000000000000000000000a000000b00000b000b00c0000000c00000000aa0000000000b00b000c00000c0000000d0000000000000000000000000000
0000000000000000000000000000a00000000b00000b00b00c00000cc00000000000aaa0000000b00b000c0000c00000000d0000000000000000000000000000
000000000000000000000000000a0000000000b0000b00b0c00000c0000000000000000aa00000b00b00c0000c000000000d0000000000000000000000000000
0000000000000000000000000000a000000000b00000b00bc0000c0000000000000000000a0000b00b0c0000c000000000d00000000000000000000000000000
0000000000000000000000000000a0000000000b0000b00bc000c000000000000000000000a000b0b00c000c0000000000d00000000000000000000000000000
00000000000000000000000000000a0000000000bb000b0b0c00c0000000000000000000000a00b0b0c000c0000000000d000000000000000000000000000000
00000000000000000000000000000aa00000000000b000b0bc0c000000000000000000000000a0bb0c000c000000000dd0000000000000000000000000000000
0000000000000000000000000000000aaa000000000bb00bbc0c000000009999999990000000a0bb0c00c00000000dd000000000000000000000000000000000
0000000000000000000000000000000000aaa00000000b00bcc00000889988999999899000000bb0c0cc000000ddd00000000000000000000000000000000000
0000000000000000000000000000000000000aaaa00000bb0bcc0008999999088888999990000bbccc0000dddd00000000000000000000000000000000000000
00000000000000000000000000000000000000000aaaaa00bbcc089ddddddddddddddaaa8990bccc00dddd000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000aaaabdddddddddd00000000ddddddddddddd0000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000aaadddddddddddddddddddddddccddddd00000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000aaaaa999d00cccbaaaaaaaaaaaccddddddd880ddddd000000000000000000000000000000000000000000
000000000000000000000000000000000000000aaaa0009909d0000cbccccccccccccaccc0000addddd000dddd00000000000000000000000000000000000000
0000000000000000000000000000000000000aa00000090090daaaa0ccccbbbb00ccccb000000998088dddddd0dddd0000000000000000000000000000000000
0000000000000000000000000000000000aaa00000009aaaaa0d00000000ccccccbbb00000000909800880000dddddddd0000000000000000000000000000000
0000000000000000000000000000000aaa0000000aaaa090080d000000000000000000000000909908000800000000000dddd000000000000000000000000000
0000000000000000000000000000aaa0000aaaaaa09009008800d000000000000000000000009090980000800000000000000000000000000000000000000000
000000000000000000000000000aaaaaaaa00000090090008800d000000000000000000000090090908000080000000000000000000000000000000000000000
00000000000000000000000000000000000000009000900808000d00000000000000000000900090900800008800000000000000000000000000000000000000
000000000000000000000000000000000000000900090008080000dd000000000000000009000090090080000080000000000000000000000000000000000000
00000000000000000000000000000000000000900009008008000000d00000000000000090000090090080000008000000000000000000000000000000000000
000000000000000000000000000000000000090000900080080000000d0000000000000900000090090008000000800000000000000000000000000000000000
0000000000000000000000000000000000009000009000800800000000dd00000000009000000090090008000000080000000000000000000000000000000000
000000000000000000000000000000000009000009000080008000000000d0000000990000000900090000800000080000000000000000000000000000000000
0000000000000000000000000000000000900000090000800080000000000dd00009000000000900009000800000008000000000000000000000000000000000
000000000000000000000000000000000900000090000080008000000000000d0090000000000900009000080000000800000000000000000000000000000000
0000000000000000000000000000000009000000900008000008000000000000dd00000000000900009000080000000800000000000000000000000000000000
000000000000000000000000000000009000000090000800000800000000000900dd000000000900009000008000000080000000000000000000000000000000
00000000000000000000000000000000900000009000080000080000000009900000dd0000009000009000008000000080000000000000000000000000000000
0000000000000000000000000000000090000000900008000000800000099000000000dd00009000009000000800000080000000000000000000000000000000
000000000000000000000000000000090000000090000800000080000990000000000000dd090000009000000800000080000000000000000000000000000000
00000000000000000000000000000009000000090000080000000809900000000000000000dd0000009000000800000080000000000000000000000000000000
0000000000000000000000000000000090000009000008000000099000000000000000000090dddd009000000800000080000000000000000000000000000000
00000000000000000000000000000000900000090000008000999080000000000000000000900000dddd00000800008800000000000000000000000000000000
000000000000000000000000000000000900000900000089990000080000000000000000090000000090ddd88888880000000000000000000000000000000000
00000000000000000000000000000000099900090099999000000000800000000000000009000000009000000800000000000000000000000000000000000000
00000000000000000000000000000000000099999900008000000000080000000000000090000000009000000800000000000000000000000000000000000000
00000000000000000000000000000000000000090000008000000000080000000000000900000000009000000800000000000000000000000000000000000000
00000000000000000000000000000000000000090000000800000000008000000000009000000000090000000800000000000000000000000000000000000000
00000000000000000000000000000000000000009000000800000000000800000000009000000000090000000800000000000000000000000000000000000000
00000000000000000000000000000000000000009000000800000000000080000000090000000000900000000800000000000000000000000000000000000000
00000000000000000000000000000000000000009000000080000000000008000000900000000000900000008000000000000000000000000000000000000000
00000000000000000000000000000000000000009000000080000000000000880009000000000009000000008000000000000000000000000000000000000000
00000000000000000000000000000000000000009000000008000000000000008090000000000009000000080000000000000000000000000000000000000000
00000000000000000000000000000000000000000900000000800000000000009900000000000090000000080000000000000000000000000000000000000000
00000000000000000000000000000000000000000090000000800000000000090088000000000090000000800000000000000000000000000000000000000000
00000000000000000000000000000000000000000090000000080000000009900000880000000800000008000000000000000000000000000000000000000000
00000000000000000000000000000000000000000009000000080000000990000000008880008000000880000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000990000008000099000000000000008888800008000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000009990000999900000000000000000080088880000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000009999008000000000000000000800000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000800000000000000088000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000088000000000008800000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000888800000880000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000088888000000000000000000000000000000000000000000000000000000000000
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__meta:cart_info_start__
cart_type: tweet
# Embed: 750 x 680
game_name: VCO Tweet
# Leave blank to use game-name
game_slug: ''
jam_info: []
tagline: A very compelling object
time_left: ''
develop_time: ''
description: |
  > The object has no applications to chemistry, physics, physiology,
  engineering, medicine, agriculture, nor any practical use of any kind. 
  Yet none dispute that it is very compelling.<br>
  <cite>- E.D.B.</cite>

  This is an animation of a [Toroflux](https://flowtoys.com/toroflux) as it expands and collapses, better
  known by some as a V.C.O.
controls: []
hints: ''
acknowledgements: ''
to_do: []
version: 0.1.0
img_alt: A rainbow spiral forming a spindle torus
about_extra: ''
number_players: [0]
__meta:cart_info_end__