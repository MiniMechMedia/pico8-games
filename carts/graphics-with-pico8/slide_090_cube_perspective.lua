
function draw()
    local SCALE = 32
    local OFFSET = 64

    unit_cube_mesh = {
        {
            {x = -1, y =  1, z =  1},
            {x = -1, y = -1, z =  1},
            {x =  1, y = -1, z =  1},
            {x =  1, y =  1, z =  1}
        },
        {
            {x = -1, y =  1, z =  -1},
            {x = -1, y = -1, z =  -1},
            {x =  1, y = -1, z =  -1},
            {x =  1, y =  1, z =  -1}
        },


        {
            {z = -1, y =  1, x =  1},
            {z = -1, y = -1, x =  1},
            {z =  1, y = -1, x =  1},
            {z =  1, y =  1, x =  1}
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
            {x = -1, z =  1, y =  -1},
            {x = -1, z = -1, y =  -1},
            {x =  1, z = -1, y =  -1},
            {x =  1, z =  1, y =  -1}
        },
    } 


    local objects = {
        -- gameObject(unit_cube_mesh,
        --     {
        --         scale={x=1, y=1, z=1},
        --         pos={x=0, y=0, z=3},
        --         rot={x=0, y=0, z=0}
        --     }
        -- ),
            gameObject(unit_cube_mesh,
            {
                scale={x=1, y=1, z=1},
                pos={x=0, y=0, z=2},
                -- pos={x=cos(time()/10), y=sin(time()/10), z=4},--+cos(time()/10)},
                rot={x=0, y=0, z=0}
            }
        )
    }

    for obj in all(objects) do
        for face in all(obj.mesh) do
            for vertex in all(face) do
                world_x = vertex.x + obj.pos.x
                world_y = vertex.y + obj.pos.y
                world_z = vertex.z + obj.pos.z

                world_x /= world_z
                world_y /= world_z

                screen_x = world_x * SCALE + OFFSET
                screen_y = world_y * SCALE + OFFSET

                line(screen_x, screen_y)
            end
            line()
        end
    end

end
