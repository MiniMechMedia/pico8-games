
function init()
    objects = {
        gameObject(unit_square_mesh,
            {
                -- rot={x=0, y=0.05, z=0.1},
                rot={x=time()/10, y=time()/10, z=0.1},
                scale=1,
                -- SCALE = 4000,
                pos = {x=0,y=0,z=2.5}
            }
        ),
    }
end

function draw()
    -- c = 2
    for obj in all(objects) do
        obj.rot = {x=time()/10, y=time()/10, z=0.1}
        for face in all(obj.mesh) do
            local a1 = face[1]
            local b1 = face[2]
            local dx1 = b1.x - a1.x
            local dy1 = b1.y - a1.y
            local dz1 = b1.z - a1.z

            local a2 = face[4]
            local b2 = face[3]
            -- a2,b2 = b2,a2
            local dx2 = b2.x - a2.x
            local dy2 = b2.y - a2.y
            local dz2 = b2.z - a2.z

            -- for vertex in all(face) do
            --     -- line(vertex.x*32+64, vertex.y*32+64)
            --     line(obj:objToScreen(vertex))
            -- end
            for i = 0, 1, 0.02 do
                local start = {
                    x = a1.x + dx1*i,
                    y = a1.y + dy1*i,
                    z = a1.z + dz1*i,
                }

                start_x, start_y = obj:objToScreen(start)

                local finish = {
                    x = a2.x + dx2*i,
                    y = a2.y + dy2*i,
                    z = a2.z + dz2*i,
                }              
                finish_x, finish_y = obj:objToScreen(finish)
                
                line(start_x, start_y, finish_x, finish_y)
            end

            -- for vertex in all(face) do
            --     line(obj:objToScreen(vertex))
            -- end

                        -- rotated = rotate(vertex, obj.rot)
            -- world_x, world_y, world_z = rotated.x, rotated.y, rotated.z

            -- screen_x = world_x * SCALE + OFFSET
            -- screen_y = world_y * SCALE + OFFSET
            

        end
    end
end
