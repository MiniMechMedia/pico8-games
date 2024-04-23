pico-8 cartridge // http://www.pico-8.com
version 41
__lua__


-- BEGIN SLIDES
#include slide_010_naive_square.lua
slide_010_naive_square = {draw = draw, name = 'slide_010_naive_square'}
#include slide_015_naive_square2.lua
slide_015_naive_square2 = {draw = draw, name = 'slide_015_naive_square2'}
#include slide_020_square_world_coords.lua
slide_020_square_world_coords = {draw = draw, name = 'slide_020_square_world_coords'}
#include slide_030_naive_transform.lua
slide_030_naive_transform = {draw = draw, name = 'slide_030_naive_transform'}
#include slide_040_2d_transform.lua
slide_040_2d_transform = {draw = draw, name = 'slide_040_2d_transform'}
slides = {
slide_010_naive_square,
slide_015_naive_square2,
slide_020_square_world_coords,
slide_030_naive_transform,
slide_040_2d_transform
}
-- END SLIDES

for i=1, #slides do
    if 
	-- slides[i].name == 'slide_015_naive_square2' or
	slides[i].name == '' or
	slides[i].name == '' or
	slides[i].name == '' or
	slides[i].name == '' or
		1==0
	then
        deli(slides, i)
        break
    end
end

function gameObject(mesh, transform)
	-- We're cheating a little bit here...
	-- TODO comment better
	if type(mesh[1].x) == 'number' then
		add(mesh, mesh[1])
	end
	transform = transform or {}
	return {
		mesh = mesh,
		scale = transform.scale,
		pos = transform.pos
	}
end


function _init()
	cartdata('minimechmedia_graphics_with_pico8_v1')
	slide_index = dget(0)
	if (slide_index < 1) slide_index = 1
	-- slides = {
	-- 	naive_square,
	-- 	square_world_coords
	-- }
end

function inc_slide_index(amount)
	slide_index += amount
	slide_index = mid(1, slide_index, #slides)
	dset(0, slide_index) -- persist slide_index to storage
end

function _update()
	if (btnp(0)) then
		inc_slide_index(-1)
	end

	if (btnp(1)) then
		inc_slide_index(1)
	end
end

function _draw()
	cls()
	color(7)
	slides[slide_index]:draw()

	-- TODO if debug
	print(slides[slide_index].name, 0, 118)
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

