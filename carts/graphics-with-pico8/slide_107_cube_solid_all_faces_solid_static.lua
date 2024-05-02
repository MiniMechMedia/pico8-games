-- The point is we show sides intersecting sorta
function init()
    objects = {
        gameObject(unit_cube_mesh,
            {
                rot={x=0, y=0.05, z=0.1},
                scale=.5
            }
        ),
    }

    for index, face in ipairs(objects[1].mesh) do
        -- face.color = index
        face.color = ({
            4,
            14,
            3,
            11,
            12,
            8
        })[index]
        -- assert(face.color != nil)
    end
end

function draw()
    -- c = 2
    for obj in all(objects) do
        -- obj.rot = {x=time()/10, y=time()/10, z=0.1}
        -- for ind, face in ipairs(obj.mesh) do
        for face in all(obj.mesh) do
            local normals = {}
            local min_x = 1000
            local max_x = -1000
            local min_y = 1000
            local max_y = -1000
            
            last_vertex = nil
            screen_coords = {}
            for vertex in all(face) do
                rotated = rotate(vertex, obj.rot)
                world_x, world_y, world_z = rotated.x, rotated.y, rotated.z
                world_x, world_y, world_z = world_x*obj.scale, world_y*obj.scale, world_z*obj.scale

                screen_x = world_x * SCALE + OFFSET
                screen_y = world_y * SCALE + OFFSET
                
                -- sides[i] = {x=screen_x, y=screen_y}
                local n = nil

                if last_vertex != nil then
                    local edge_x = last_vertex.x - screen_x
                    local edge_y = last_vertex.y - screen_y
                    local mag = sqrt(edge_x*edge_x + edge_y*edge_y)
                    n = {x=-edge_y/mag, y=edge_x/mag}
                    -- add(normals, n)
                    add(normals, {
                        n_end_x = n.x,
                        n_end_y = n.y,
                        p_start_x = screen_x,
                        p_start_y = screen_y
                    })
                    -- color(c)
                    -- c+=1
                    -- line(screen_x, screen_y, last_vertex.x, last_vertex.y)
                    -- line(screen_x, screen_y, screen_x + n.x * 10, screen_y + n.y * 10)
                end

                last_vertex = {x=screen_x, y=screen_y}
                -- line(screen_x, screen_y, 7)
                -- line(screen_x, screen_y)
                min_x = min(min_x, screen_x)
                max_x = max(max_x, screen_x)
                min_y = min(min_y, screen_y)
                max_y = max(max_y, screen_y)

                add(screen_coords, last_vertex)
            end
            line()

            for x = min_x, max_x do
                for y = min_y, max_y do
                    -- is_inside = true
                    dot_products = {}
                    for n in all(normals) do
                        p_x = n.p_start_x - x
                        p_y = n.p_start_y - y
                        dot = p_x * n.n_end_x + p_y * n.n_end_y
                        add(dot_products, dot)
                        -- if dot < 0 then
                        --     is_inside = false
                        -- end
                    end
                    local is_inside = true
                    for dot in all(dot_products) do
                        if sgn(dot) != sgn(dot_products[1]) then
                            is_inside = false
                            break
                        end
                    end
                    if is_inside then
                        pset(x,y,face.color)
                    end
                end
            end
            -- for vertex in all(screen_coords) do
            --     line(vertex.x, vertex.y, 7)
            -- end
        -- for n in all(normals) do
            -- for i=1,4 do
            --     v = face[i]
            --     n = normals[i]
            --     line(v.x,v.y, v.x+n.x,v.y+n.y)
            -- end
        end
    end
end
