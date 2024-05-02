pico-8 cartridge // http://www.pico-8.com
version 42
__lua__







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



-- TODO be smarter...
function vecmul(matrix, vector)
	vector = {vector.x, vector.y, vector.z}
    local result = {0, 0, 0}
    for i=1, #matrix do
        for j=1, #matrix[i] do
            result[i] = result[i] + matrix[i][j] * vector[j]
        end
    end
    -- return result
	return {
		x=result[1],
		y=result[2],
		z=result[3]
	}
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

SCALE = 32
OFFSET = 64

unit_square_mesh = {
	{
        {x = -1, y =  1, z = 1},
        {x = -1, y = -1, z = 1},
        {x =  1, y = -1, z = 1},
        {x =  1, y =  1, z = 1}
    }
}

unit_cube_mesh = {
	{
		{z = -1, y =  1, x =  1},
		{z = -1, y = -1, x =  1},
		{z =  1, y = -1, x =  1},
		{z =  1, y =  1, x =  1}
	},
	{
		{x = -1, z =  1, y =  -1},
		{x = -1, z = -1, y =  -1},
		{x =  1, z = -1, y =  -1},
		{x =  1, z =  1, y =  -1}
	},
	{
		{x = -1, y =  1, z =  1},
		{x = -1, y = -1, z =  1},
		{x =  1, y = -1, z =  1},
		{x =  1, y =  1, z =  1}
	},

	{
		{z = -1, y =  1, x =  -1},
		{z = -1, y = -1, x =  -1},
		{z =  1, y = -1, x =  -1},
		{z =  1, y =  1, x =  -1}
	},

	
	{
		{x = -1, z =  1, y =  1},
		{x = -1, z = -1, y =  1},
		{x =  1, z = -1, y =  1},
		{x =  1, z =  1, y =  1}
	},


	{
		{x = -1, y =  1, z =  -1},
		{x = -1, y = -1, z =  -1},
		{x =  1, y = -1, z =  -1},
		{x =  1, y =  1, z =  -1}
	},
} 

function emptyinit()
end

startTime = t()

function time()
	return t() - startTime
end

function sort(a, key)
    for i=1,#a do
        local j = i
        while j > 1 and key(a[j-1]) > key(a[j]) do
            a[j],a[j-1] = a[j-1],a[j]
            j = j - 1
        end
    end
	return a
end
function gameObject(mesh, transform)
	-- We're cheating a little bit here...
	-- TODO comment better
	if type(mesh[1].x) == 'number' then
		add(mesh, mesh[1])
	else
		for face in all(mesh) do
			local sum_x = 0
			local sum_y = 0
			local sum_z = 0
			local count = 0
			for vertex in all(face) do
				sum_x += vertex.x
				sum_y += vertex.y
				sum_z += vertex.z or 0
				count += 1
			end
			face.center = {x=sum_x/count, y=sum_y/count, z=sum_z/count}
			add(face, face[1])
		end
	end
	transform = transform or {}
	return {
		mesh = mesh,
		scale = transform.scale or 1,
		pos = transform.pos or {x=0,y=0,z=0},
		rot = transform.rot or {x=0,y=0,z=0},
		SCALE = transform.SCALE or 32,
		OFFSET = transform.OFFSET or 64,
		-- Only for 3d game objects
		objToScreen = function(self, obj_point)
			local world_x, world_y, world_z = self:objToWorld(obj_point)

			local SCALE = 32
			local OFFSET = 64
			
			local screen_x = world_x / world_z*3 * self.SCALE + self.OFFSET
			local screen_y = world_y / world_z*3 * self.SCALE + self.OFFSET

			return screen_x, screen_y
		end,
		objToWorld = function(self, obj_point)
			local rotated = rotate(obj_point, self.rot)
			local world_x = rotated.x * self.scale + self.pos.x
			local world_y = rotated.y * self.scale + self.pos.y
			local world_z = rotated.z * self.scale + self.pos.z
			return world_x, world_y, world_z
		end
	}
end

function rotate(vector, euler_angles)
	alpha, beta, gamma = euler_angles.x, euler_angles.y, euler_angles.z
	yaw = {
		{cos(alpha), -sin(alpha), 0},
		{sin(alpha), cos(alpha), 0},
		{0, 0, 1}
	}

	pitch = {
		{cos(beta), 0, sin(beta)},
		{0, 1, 0},
		{-sin(beta), 0, cos(beta)}
	}

	roll = {
		{1, 0, 0},
		{0, cos(gamma), -sin(gamma)},
		{0, sin(gamma), cos(gamma)}
	}
	
	-- Multiply yaw by pitch, then the result by roll
	local yaw_pitch = matmul(yaw, pitch)
	local rotation_matrix = matmul(yaw_pitch, roll)
	return vecmul(rotation_matrix, vector)
end


function _init()
	for name in all({
		'slide_082_objToScreen',
		'slide_093_cube_static_rot_persp'
	}) do
		for slide in all(slides) do
			if slide.name == name then
				del(slides, slide)
			end
		end
	end
	
	cartdata('minimechmedia_graphics_with_pico8_v1')
	slide_index = dget(0)
	slide_index = mid(1, slide_index, #slides)
	inc_slide_index(0, slide_index)

end

function inc_slide_index(amount, absolute)
	local original = slide_index
	slide_index += amount
	slide_index = mid(1, slide_index, #slides)
	if absolute then
		slide_index = absolute
	end
	dset(0, slide_index) -- persist slide_index to storage
	if original != slide_index or absolute then
		slides[slide_index]:init()
		printh(slides[slide_index].name .. '.lua')
		startTime = t()
	end
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

	if debug_mode or true then
		color(11)
        print("CPU: " .. stat(1), 5, 5, 7)
        print("Memory: " .. stat(0), 5, 15, 7)
    end
end




-- BEGIN SLIDES
#include slide_010_naive_square.lua
slide_010_naive_square = {draw = draw, init=emptyinit, name = 'slide_010_naive_square'}
#include slide_015_naive_square2.lua
slide_015_naive_square2 = {draw = draw, init=emptyinit, name = 'slide_015_naive_square2'}
#include slide_020_square_world_coords.lua
slide_020_square_world_coords = {draw = draw, init=emptyinit, name = 'slide_020_square_world_coords'}
#include slide_030_naive_transform.lua
slide_030_naive_transform = {draw = draw, init=emptyinit, name = 'slide_030_naive_transform'}
#include slide_040_2d_transform.lua
slide_040_2d_transform = {draw = draw, init=emptyinit, name = 'slide_040_2d_transform'}
#include slide_050_2d_transform_rot.lua
slide_050_2d_transform_rot = {draw = draw, init=emptyinit, name = 'slide_050_2d_transform_rot'}
#include slide_060_matrices.lua
slide_060_matrices = {draw = draw, init=emptyinit, name = 'slide_060_matrices'}
#include slide_070_naive_cube.lua
slide_070_naive_cube = {draw = draw, init=emptyinit, name = 'slide_070_naive_cube'}
#include slide_080_cube_rotation.lua
slide_080_cube_rotation = {draw = draw, init=emptyinit, name = 'slide_080_cube_rotation'}
#include slide_082_objToScreen.lua
slide_082_objToScreen = {draw = draw, init=emptyinit, name = 'slide_082_objToScreen'}
#include slide_090_cube_perspective.lua
slide_090_cube_perspective = {draw = draw, init=emptyinit, name = 'slide_090_cube_perspective'}
#include slide_093_cube_static_rot_persp.lua
slide_093_cube_static_rot_persp = {draw = draw, init=emptyinit, name = 'slide_093_cube_static_rot_persp'}
#include slide_095_cube_rot_persp.lua
slide_095_cube_rot_persp = {draw = draw, init=emptyinit, name = 'slide_095_cube_rot_persp'}
#include slide_100_cube_solid_faces_baseline.lua
slide_100_cube_solid_faces_baseline = {draw = draw, init=emptyinit, name = 'slide_100_cube_solid_faces_baseline'}
#include slide_102_cube_solid_faces_one_face.lua
slide_102_cube_solid_faces_one_face = {draw = draw, init=emptyinit, name = 'slide_102_cube_solid_faces_one_face'}
#include slide_105_cube_solid_single_face_normals.lua
slide_105_cube_solid_single_face_normals = {draw = draw, init=emptyinit, name = 'slide_105_cube_solid_single_face_normals'}
#include slide_106_cube_solid_single_face_filled.lua
slide_106_cube_solid_single_face_filled = {draw = draw, init=init, name = 'slide_106_cube_solid_single_face_filled'}
#include slide_107_cube_solid_all_faces_solid_static.lua
slide_107_cube_solid_all_faces_solid_static = {draw = draw, init=init, name = 'slide_107_cube_solid_all_faces_solid_static'}
#include slide_110_cube_solid_all_faces_solid_rotating.lua
slide_110_cube_solid_all_faces_solid_rotating = {draw = draw, init=init, name = 'slide_110_cube_solid_all_faces_solid_rotating'}
#include slide_115_solid_depth_sort.lua
slide_115_solid_depth_sort = {draw = draw, init=init, name = 'slide_115_solid_depth_sort'}
#include slide_117_solid_multi_object_baseline.lua
slide_117_solid_multi_object_baseline = {draw = draw, init=init, name = 'slide_117_solid_multi_object_baseline'}
#include slide_119_depth_sort_objects.lua
slide_119_depth_sort_objects = {draw = draw, init=init, name = 'slide_119_depth_sort_objects'}
slides = {
slide_010_naive_square,
slide_015_naive_square2,
slide_020_square_world_coords,
slide_030_naive_transform,
slide_040_2d_transform,
slide_050_2d_transform_rot,
slide_060_matrices,
slide_070_naive_cube,
slide_080_cube_rotation,
slide_082_objToScreen,
slide_090_cube_perspective,
slide_093_cube_static_rot_persp,
slide_095_cube_rot_persp,
slide_100_cube_solid_faces_baseline,
slide_102_cube_solid_faces_one_face,
slide_105_cube_solid_single_face_normals,
slide_106_cube_solid_single_face_filled,
slide_107_cube_solid_all_faces_solid_static,
slide_110_cube_solid_all_faces_solid_rotating,
slide_115_solid_depth_sort,
slide_117_solid_multi_object_baseline,
slide_119_depth_sort_objects
}
-- END SLIDES

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
