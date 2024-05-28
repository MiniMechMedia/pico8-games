
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
                scale=1,
                pos={x=0, y=0, z=4},
                rot={x=0, y=0, z=0},
            }
        )
    }

    for obj in all(objects) do
        for face in all(obj.mesh) do
            for vertex in all(face) do
                obj_x = vertex.x * obj.scale
                obj_y = vertex.y * obj.scale
                obj_z = vertex.z * obj.scale

                temp_x = obj_x      -- TODO rotate
                temp_y = obj_y
                temp_z = obj_z

                world_x = temp_x + obj.pos.x
                world_y = temp_y + obj.pos.y
                world_z = temp_z + obj.pos.z

                screen_x = world_x * SCALE + OFFSET
                screen_y = world_y * SCALE + OFFSET
                -- ?? = world_z
                line(screen_x, screen_y)
            end
                                                                                                                    line()
        end
    end
end
