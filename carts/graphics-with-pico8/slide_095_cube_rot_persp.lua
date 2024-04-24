
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
                rot={x=time()/10, y=time()/10, z=time()/10}
            }
        ),
    }

    for obj in all(objects) do
        for face in all(obj.mesh) do
            for vertex in all(face) do

                alpha, beta, gamma = obj.rot.x, obj.rot.y, obj.rot.z
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
                world_vec = vecmul(rotation_matrix, vertex)
                world_x, world_y, world_z = world_vec.x, world_vec.y, world_vec.z

                world_z += 3

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
