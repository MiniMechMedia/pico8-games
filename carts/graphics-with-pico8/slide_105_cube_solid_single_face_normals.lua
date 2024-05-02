
function draw()
    local objects = {
        gameObject(unit_square_mesh,
            {
                rot={x=0, y=0.05, z=0.1},
                -- rot={x=time()/10, y=time()/10, z=0.1},
            }
        ),
    }

    for obj in all(objects) do
        for face in all(obj.mesh) do
            local normals = {}
            last_vertex = nil
            for vertex in all(face) do
                rotated = rotate(vertex, obj.rot)
                world_x, world_y, world_z = rotated.x, rotated.y, rotated.z

                screen_x = world_x * SCALE + OFFSET
                screen_y = world_y * SCALE + OFFSET
                
                -- sides[i] = {x=screen_x, y=screen_y}
                local n = nil

                if last_vertex != nil then
                    local edge_x = last_vertex.x - screen_x
                    local edge_y = last_vertex.y - screen_y
                    local mag = sqrt(edge_x*edge_x + edge_y*edge_y)
                    n = {x=-edge_y/mag, y=edge_x/mag}
                    add(normals, n)

                    line(screen_x, screen_y, last_vertex.x, last_vertex.y)
                    line(screen_x, screen_y, screen_x + n.x * 10, screen_y + n.y * 10)
                end

                last_vertex = {x=screen_x, y=screen_y}

                -- line(screen_x, screen_y)
                
            end
            line()

        -- for n in all(normals) do
            -- for i=1,4 do
            --     v = face[i]
            --     n = normals[i]
            --     line(v.x,v.y, v.x+n.x,v.y+n.y)
            -- end
        end
    end
end
