
function draw()
    SCALE = 32
    OFFSET = 64

    local unit_cube_mesh = {
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
                scale=3,
                pos={x=0, y=0, z=8},
                rot={x=time()/10, y=time()/10, z=time()/10},
            }
        )
    }

    for obj in all(objects) do
        for face in all(obj.mesh) do
            for vertex in all(face) do
                obj_x = vertex.x * obj.scale
                obj_y = vertex.y * obj.scale
                obj_z = vertex.z * obj.scale

                local a, b, c = obj.rot.z, obj.rot.y, obj.rot.x
                temp_x = (
                    cos(b)*cos(c)*obj_x + 
                    (sin(a)*sin(b)*cos(c)-cos(a)*sin(c))*obj_y +
                    (cos(a)*sin(b)*cos(c)+sin(a)*sin(c))*obj_z
                )
                temp_y = (
                    cos(b)*sin(c)*obj_x +
                    (sin(a)*sin(b)*sin(c)+cos(a)*cos(c))*obj_y +
                    (cos(a)*sin(b)*sin(c)-sin(a)*cos(c))*obj_z
                )
                temp_z = (
                    -sin(b)*obj_x + 
                    sin(a)*cos(b)*obj_y +
                    cos(a)*cos(b)*obj_z
                )
                
                world_x = temp_x + obj.pos.x
                world_y = temp_y + obj.pos.y
                world_z = temp_z + obj.pos.z

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
