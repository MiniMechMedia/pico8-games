
function init()
    objects = {
        gameObject(unit_cube_mesh,
            {
                rot={x=0, y=0.05, z=0.1},
                pos={x=0, y=0, z=5},
                scale=.5
            }
        ),
    }
end

light = {x=0,y=0,z=-1}
light_map = {
    -- 0,
    0 + 128,
    0,
    1 + 128,
    1,
    5 + 128,
    5,
    13 + 128,
    13,
    6 + 128,
    6,
    7 + 128,
    7,
}

pal(2, 0+128, 1)
pal(3, 1+128, 1)
pal(4, 5+128, 1)
pal(8, 13+128, 1)
pal(9, 6+128, 1)
pal(10, 7+128, 1)

light_map = {
    2,
    0,
    3,
    1,
    4,
    5,
    8,
    13,
    9,
    6,
    -- 10,
    7,
}
-- pal(4, )

-- light_map = {
--     1,
--     2,
--     3,
--     4,
--     5,
--     6,
--     7,
--     8,
--     9,
--     10,
--     11,
--     12,
-- }



function draw()
    -- for i, v in ipairs(light_map) do
    --     pal(i,v,1)
    -- end
    -- c = 2
    for obj in sort_objects(objects) do
        obj.rot = {x=time()/10, y=time()/5, z=time()/9}
        -- get_center_z = function() return rnd() end
        -- for ind, face in ipairs(obj.mesh) do
        for face in sort_faces(obj.mesh, obj) do
            -- local nx,ny,nz=obj:objToWorld(face.normal)
            local n = rotate(face.normal, obj.rot)
            local dot = light.x*n.x + light.y*n.y + light.z*n.z
            -- dot = abs(dot)*6
            local col = light_map[dot*#light_map\1]
            -- col=2
            fill_polygon(face, obj, col)
            -- print(dot, 50,50,7)
            -- print(dot*#light_map, 40,40,7)
            -- print(color, 64,64,7)
            -- color(7)
            -- print(n.x, 5,40)
            -- print(n.y)
            -- print(n.z)
            print(dot*#light_map\1)


            -- break
        end
    end
end