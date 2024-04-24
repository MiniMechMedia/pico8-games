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
#include slide_050_2d_transform_rot.lua
slide_050_2d_transform_rot = {draw = draw, name = 'slide_050_2d_transform_rot'}
#include slide_060_matrices.lua
slide_060_matrices = {draw = draw, name = 'slide_060_matrices'}
#include slide_070_naive_cube.lua
slide_070_naive_cube = {draw = draw, name = 'slide_070_naive_cube'}
#include slide_080_cube_rotation.lua
slide_080_cube_rotation = {draw = draw, name = 'slide_080_cube_rotation'}
slides = {
slide_010_naive_square,
slide_015_naive_square2,
slide_020_square_world_coords,
slide_030_naive_transform,
slide_040_2d_transform,
slide_050_2d_transform_rot,
slide_060_matrices,
slide_070_naive_cube,
slide_080_cube_rotation
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
	else
		for face in all(mesh) do
			add(face, face[1])
		end
	end
	transform = transform or {}
	return {
		mesh = mesh,
		scale = transform.scale,
		pos = transform.pos,
		rot = transform.rot
	}
end






function matmul(mat1, mat2)
    local result = {}
    for i=1, #mat1 do
        result[i] = {}
        for j=1, #mat2[1] do
            local sum = 0
            for k=1, #mat1[1] do
                sum = sum + mat1[i][k] * mat2[k][j]
            end
            result[i][j] = sum
        end
    end
    return result
end



matrix1 = {
	{1, 2, 3},
	{4, 5, 6},
	{7, 8, 9}
}

vec = {1, 2, 3}

function vecmul(matrix, vector)
    local result = {0, 0, 0}
    for i=1, #matrix do
        for j=1, #matrix[i] do
            result[i] = result[i] + matrix[i][j] * vector[j]
        end
    end
    return result
end

function matadd(mat1, mat2)
    local result = {}
    for i=1, #mat1 do
        result[i] = {}
        for j=1, #mat1[1] do
            result[i][j] = mat1[i][j] + mat2[i][j]
        end
    end
    return result
end




function _init()

	local matrix = {
        {1, 2, 3},
        {4, 5, 6},
        {7, 8, 9}
    }
    local vector = {1, 2, 3}
    local expected_result = {14, 32, 50}
    local result = vecmul(matrix, vector)
    for i=1, #result do
        assert(result[i] == expected_result[i], "Test failed: element " .. i .. " is not correct")
    end
    print("Test passed: vecmul function works correctly")
		
	cartdata('minimechmedia_graphics_with_pico8_v1')
	slide_index = dget(0)
	slide_index = mid(1, slide_index, #slides)
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

