
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
                rot={x=0, y=0, z=0}
            }
        ),
    }

    for obj in all(objects) do
        for face in all(obj.mesh) do
            for vertex in all(face) do

                rot={x=time()/10, y=time()/10, z=time()/10}

                -- Incorporating rotation using Euler angles
                temp_x = vertex.x * cos(rot.y) * cos(rot.z) - vertex.y * sin(rot.x) * sin(rot.y) * cos(rot.z) + vertex.y * cos(rot.x) * sin(rot.z) + vertex.z * sin(rot.x) * cos(rot.y) * cos(rot.z) + vertex.z * sin(rot.x) * sin(rot.z)
                temp_y = vertex.x * cos(rot.y) * sin(rot.z) + vertex.y * sin(rot.x) * sin(rot.y) * sin(rot.z) - vertex.y * cos(rot.x) * cos(rot.z) + vertex.z * sin(rot.x) * cos(rot.y) * sin(rot.z) - vertex.z * sin(rot.x) * cos(rot.z)
                temp_z = -vertex.x * sin(rot.y) + vertex.y * sin(rot.x) * cos(rot.y) + vertex.z * cos(rot.x) * cos(rot.y)
                world_x = temp_x
                world_y = temp_y
                world_z = temp_z

                screen_x = world_x * SCALE + OFFSET
                screen_y = world_y * SCALE + OFFSET

                line(screen_x, screen_y)
            end
            line()
        end
    end

end
