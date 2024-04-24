
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
        gameObject(unit_cube_mesh,
            {
                scale={x=1, y=1, z=1},
                pos={x=0, y=0, z=0},
                -- rot={x=0, y=0, z=0},
                rot={x=0, y=0.05, z=0.1},
                -- rot={x=0, y=time()/10, z=0.05}
            }
        ),
    }

    for obj in all(objects) do
        for face in all(obj.mesh) do
            for vertex in all(face) do

                rotated = rotate(vertex, obj.rot)
                
                world_x, world_y, world_z = rotated.x, rotated.y, rotated.z

                screen_x = world_x * SCALE + OFFSET
                screen_y = world_y * SCALE + OFFSET

                line(screen_x, screen_y)
            end
            line()
        end
    end

end
