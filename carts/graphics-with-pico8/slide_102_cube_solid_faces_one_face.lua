
function draw()
    local objects = {
        gameObject(unit_square_mesh,
            {
                -- rot={x=0, y=0.05, z=0.1},
                -- rot={x=0, y=0.0, z=0.4},
                -- pos = {x=0,y=0,z=2.5}
                -- rot={x=0, y=0.0, z=0.4 },
                rot={x=0, y=0.0, z=0.1 },
                pos = {x=0,y=0,z=4},
            }
        ),
    }

    for obj in all(objects) do
        for face in all(obj.mesh) do
            local vectors = {}
            local last_vertex = nil
            for vertex in all(face) do
                -- rotated = rotate(vertex, obj.rot)
                -- world_x, world_y, world_z = rotated.x, rotated.y, rotated.z

                -- screen_x = world_x * SCALE + OFFSET
                -- screen_y = world_y * SCALE + OFFSET
                screen_x, screen_y = obj:objToScreen(vertex)
                -- sides[i] = {x=screen_x, y=screen_y}

                if last_vertex != nil then
                    add(vectors, {
                        x = screen_x - last_vertex.x,
                        y = screen_y - last_vertex.y
                    })
                end

                last_vertex = {x=screen_x, y=screen_y}

                line(screen_x, screen_y)
            end
            line()

            -- for v in all(vectors) do
            --     line(64,64, 64+v.x/3, 64+v.y/3)
            -- end
            
        end
    end

end
