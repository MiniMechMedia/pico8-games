pico-8 cartridge // http://www.pico-8.com
version 39
__lua__
--digital countdown tweet        v0.1.0
--mini mech media


cls()--
-- Our overall loop counter
k=0--
::_::--
-- 3 for loops have been inlined into the main loop:
-- One to loop over the digit we want to draw,
-- one to loop over the segments within the digit,
-- one to loop over offsets to make the segment thick
-- 6 digits * 15 segment grid points * 3 thickness offsets = 270 iterations needed
k+=1if(k==270)k=0flip()
-- Need to do some math to extract the relevant index for each loop
segment_index_f=k%15--
digit_index_p=k\15%6--
segment_offset_i=k\90-1--
-- Space out each digit 20 pixels apart, with an extra
-- 4 pixels to separate hours from minutes from seconds
digit_xoffset_j=digit_index_p*20-5+digit_index_p\2*4--
-- Each segment consists of multiple lines. The length
-- and position of each line is modified to make the
-- segment taper off. These offsets make that taper happen
xoff1_a,yoff1_c,yoff2_d=-5+abs(segment_offset_i),segment_offset_i,segment_offset_i
xoff2_b=-xoff1_a
-- The center of the segment we are about to draw.
-- A key insight is that the centers of each segment
-- can be positioned on a 3x5 grid, but skipping
-- every other grid point. i.e.
-- + @ +
-- @ + @
-- + @ +
-- @ + @
-- + @ +
x,y=segment_index_f\5+1,segment_index_f%5+1--
-- Seconds portion of the timestamp
-- The negative and mod results in counting down from 59.999 to 0
-- and looping back at the end. Also need to truncate to a whole number
seconds_=-t()%60\1
if(x!=2)--[[then
    -- If the segment is vertical instead of horizontal, swap
    -- those values we just calculated
    ]]xoff1_a,xoff2_b,yoff1_c,yoff2_d=yoff1_c,yoff2_d,xoff1_a,xoff2_b
--[[end]]
-- Remember how we said only every other grid point has a segment?
-- That can be concisely described by the parity of the sum of 
-- the coordinates
if((x+y)%2>0)--[[then
    ]]line(digit_xoffset_j+x*7+xoff1_a,y*7+yoff1_c,--[[
    ]]digit_xoffset_j+x*7+xoff2_b,y*7+yoff2_d,--[[
    -- Seven-segment patterns for digits 0-9
    -- The pattern for each digit is defined by
    -- a 7-bit mask. Although to save characters
    -- we invert the mask so a 0 bit means the
    -- segment is lit up
    ]]({8,31,65,3,22,34,32,27,0,2})[--[[
        -- Table to hold each digit of the timestamp
        -- We don't have enough characters to actually
        -- parse out the whole timestamp, so we fake
        -- all except the seconds portion
        ]]({2,3,5,9,seconds_\10,seconds_%10})[digit_index_p+1]--[[
    -- Lua tables start at index 1, so whatever digit
    -- we need to draw, access the bitmask table as
    -- required
    ]]+1]--[[
    -- Check if the segment_index bit is on
    ]]&1<<segment_index_f\2>0--[[
    -- Select on or off color using poor man's 
    -- ternary operator
    ]]and 1or 9--[[
    ]])
--[[end]]
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
00000999999999000000000009999999990000000000000009999999990000000000099999999900000000000000099999999900000000000111111111000000
00009999999999900000000099999999999000000000000099999999999000000000999999999990000000000000999999999990000000001111111111100000
00000999999999000000000009999999990000000000000009999999990000000000099999999900000000000000099999999900000000000111111111000000
00100000000000009000001000000000000090000000009000000000000010000090000000000000900000000090000000000000100000900000000000009000
01110000000000099900011100000000000999000000099900000000000111000999000000000009990000000999000000000001110009990000000000099900
01110000000000099900011100000000000999000000099900000000000111000999000000000009990000000999000000000001110009990000000000099900
01110000000000099900011100000000000999000000099900000000000111000999000000000009990000000999000000000001110009990000000000099900
01110000000000099900011100000000000999000000099900000000000111000999000000000009990000000999000000000001110009990000000000099900
01110000000000099900011100000000000999000000099900000000000111000999000000000009990000000999000000000001110009990000000000099900
01110000000000099900011100000000000999000000099900000000000111000999000000000009990000000999000000000001110009990000000000099900
01110000000000099900011100000000000999000000099900000000000111000999000000000009990000000999000000000001110009990000000000099900
01110000000000099900011100000000000999000000099900000000000111000999000000000009990000000999000000000001110009990000000000099900
01110000000000099900011100000000000999000000099900000000000111000999000000000009990000000999000000000001110009990000000000099900
00100000000000009000001000000000000090000000009000000000000010000090000000000000900000000090000000000000100000900000000000009000
00000999999999000000000009999999990000000000000009999999990000000000099999999900000000000000099999999900000000000999999999000000
00009999999999900000000099999999999000000000000099999999999000000000999999999990000000000000999999999990000000009999999999900000
00000999999999000000000009999999990000000000000009999999990000000000099999999900000000000000099999999900000000000999999999000000
00900000000000001000001000000000000090000000001000000000000090000010000000000000900000000010000000000000900000100000000000009000
09990000000000011100011100000000000999000000011100000000000999000111000000000009990000000111000000000009990001110000000000099900
09990000000000011100011100000000000999000000011100000000000999000111000000000009990000000111000000000009990001110000000000099900
09990000000000011100011100000000000999000000011100000000000999000111000000000009990000000111000000000009990001110000000000099900
09990000000000011100011100000000000999000000011100000000000999000111000000000009990000000111000000000009990001110000000000099900
09990000000000011100011100000000000999000000011100000000000999000111000000000009990000000111000000000009990001110000000000099900
09990000000000011100011100000000000999000000011100000000000999000111000000000009990000000111000000000009990001110000000000099900
09990000000000011100011100000000000999000000011100000000000999000111000000000009990000000111000000000009990001110000000000099900
09990000000000011100011100000000000999000000011100000000000999000111000000000009990000000111000000000009990001110000000000099900
09990000000000011100011100000000000999000000011100000000000999000111000000000009990000000111000000000009990001110000000000099900
00900000000000001000001000000000000090000000001000000000000090000010000000000000900000000010000000000000900000100000000000009000
00000999999999000000000009999999990000000000000009999999990000000000099999999900000000000000099999999900000000000111111111000000
00009999999999900000000099999999999000000000000099999999999000000000999999999990000000000000999999999990000000001111111111100000
00000999999999000000000009999999990000000000000009999999990000000000099999999900000000000000099999999900000000000111111111000000
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
game_name: Digital Countdown Tweet
# Leave blank to use game-name
game_slug: ''
jam_info: []
tagline: A tweetable seven-segment display countdown
time_left: ''
develop_time: ''
description: |
  A [seven-segment display](https://en.wikipedia.org/wiki/Seven-segment_display) countdown implemented in a tweetcart.
controls: []
hints: ''
acknowledgements: |
  Based on the clock from the [24 TV Series](https://en.wikipedia.org/wiki/24_(TV_series))
to_do: []
version: 0.1.0
img_alt: Low resolution pixel art of a digital clock's seven-segment display showing the countdown from 23:59:54
about_extra: ''
number_players: [0]
__meta:cart_info_end__