
function draw()
    local objects = {
        gameObject(unit_square_mesh,
            {
                rot={x=0, y=0.05, z=0.1},
            }
        ),
    }

    for obj in all(objects) do
        for face in all(obj.mesh) do
            local sides = {}
            last_vertex = nil
            for vertex in all(face) do
                rotated = rotate(vertex, obj.rot)
                world_x, world_y, world_z = rotated.x, rotated.y, rotated.z

                screen_x = world_x * SCALE + OFFSET
                screen_y = world_y * SCALE + OFFSET
                
                -- sides[i] = {x=screen_x, y=screen_y}

                if last_vertex != nil then
                    add(sides, {
                        x = last_vertex.x - screen_x,
                        y = last_vertex.y - screen_y
                    })
                end

                last_vertex = {x=screen_x, y=screen_y}

                line(screen_x, screen_y)
            end
            line()
        end
    end

end
