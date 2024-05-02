
function init()
    objects = {
        gameObject(unit_cube_mesh,
            {
                -- rot={x=0, y=0.05, z=0.1},
                -- rot={x=time()/10, y=time()/10, z=0.1},
                rot={x=.1,y=.1,z=0},
                scale=1,
                -- SCALE = 4000,
                pos = {x=0,y=0,z=2.5}
            }
        ),
    }
end

function draw()
    -- c = 2
    print('should show a static, solid cube. Should be passable')
    -- print('do not want to use weird line rasterizing algo')
    if (1>0) return
    for obj in all(objects) do
        -- obj.rot = {x=time()/10, y=time()/10, z=0.1}
        for face in all(obj.mesh) do
            local a1 = face[1]
            local b1 = face[2]
            local dx1 = b1.x - a1.x
            local dy1 = b1.y - a1.y
            local dz1 = b1.z - a1.z

            local a2 = face[4]
            local b2 = face[3]
            local dx2 = b2.x - a2.x
            local dy2 = b2.y - a2.y
            local dz2 = b2.z - a2.z

            for i = 0, 1, 0.03 do
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

                i+=0.1
                local finish = {
                    x = a2.x + dx2*i,
                    y = a2.y + dy2*i,
                    z = a2.z + dz2*i,
                }              
                finish_x, finish_y = obj:objToScreen(finish)
                line(start_x, start_y, finish_x, finish_y)

            end


            local a1 = face[1]
            local b1 = face[4]
            local dx1 = b1.x - a1.x
            local dy1 = b1.y - a1.y
            local dz1 = b1.z - a1.z

            local a2 = face[2]
            local b2 = face[3]
            local dx2 = b2.x - a2.x
            local dy2 = b2.y - a2.y
            local dz2 = b2.z - a2.z

            for i = 0, 1, 0.03 do
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

                i+=0.1
                local finish = {
                    x = a2.x + dx2*i,
                    y = a2.y + dy2*i,
                    z = a2.z + dz2*i,
                }              
                finish_x, finish_y = obj:objToScreen(finish)
                line(start_x, start_y, finish_x, finish_y)

            end

        end
    end
end
