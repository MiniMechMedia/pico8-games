
function vec3(x,y,z)
    return {
        x=x,y=y,z=z
    }
end

function polygon(vertex_list)
    return {
        vertex_list = vertex_list
    }
end

function dot(u, v)
    return u.x*v.x + u.y*v.y
end

function world_to_screen(world)
    return {
        x=world.x*32+64,
        y=world.y*32+64
    } 
end

-- Assuming vec2
function point_in_polygon(vertex_list, point)
    local num_vertices = #vertex_list
    for i=1, num_vertices do
        local a = world_to_screen(vertex_list[i])
        local b = world_to_screen(vertex_list[(i % num_vertices) + 1])

        local edge_x, edge_y = b.x - a.x, b.y - a.y
        local normal_x, normal_y = edge_y, -edge_x
        local point_x, point_y = point.x - a.x, point.y - a.y
        -- print(normal_x)
        -- local dotProduct = dot(normalVector, pointVector)
        local dot = normal_x * point_x + normal_y * point_y
        -- print(dot)
        if dot < 0 then
            return false -- Point is outside the polygon
        end
    end
    return true -- Point is inside the polygon
end

local cubeFaces = {
    polygon({vec3(-1,-1,-1), vec3(-1,1,-1), vec3(1,1,-1), vec3(1,-1,-1)}),
    polygon({vec3(-1,-1,-1), vec3(-1,1,-1), vec3(1,1,-1), vec3(1,-1,-1)}),
    polygon({vec3(-1,-1,-1), vec3(-1,1,-1), vec3(1,1,-1), vec3(1,-1,-1)}),
    polygon({vec3(-1,-1,-1), vec3(-1,1,-1), vec3(1,1,-1), vec3(1,-1,-1)}),
    polygon({vec3(-1,-1,-1), vec3(-1,1,-1), vec3(1,1,-1), vec3(1,-1,-1)}),
    polygon({vec3(-1,-1,-1), vec3(-1,1,-1), vec3(1,1,-1), vec3(1,-1,-1)}),
    -- {x = 0, y = 0, z = 0}, -- Vertex 0
    -- {x = 1, y = 0, z = 0}, -- Vertex 1
    -- {x = 1, y = 0, z = 1}, -- Vertex 3, revisiting through the cube
    -- {x = 1, y = 0, z = 0}, -- Vertex 1, backtrack
    -- {x = 1, y = 1, z = 0}, -- Vertex 5, moving up
    -- {x = 1, y = 1, z = 1}, -- Vertex 7, across the top
    -- {x = 0, y = 1, z = 1}, -- Vertex 6, completing top face traversal
    -- {x = 0, y = 0, z = 1}, -- Vertex 2, moving down
    -- {x = 1, y = 0, z = 1}, -- Vertex 3, completing bottom face traversal
    -- {x = 1, y = 1, z = 1}, -- Vertex 7, diagonally across the cube
    -- {x = 1, y = 1, z = 0}, -- Vertex 5, backtrack on the top face
    -- {x = 0, y = 1, z = 0}, -- Vertex 4, completing top face traversal
    -- {x = 0, y = 0, z = 0}, -- Vertex 0, moving down
}

function fillPolygon(polygon)
    for v in all(polygon.vertex_list) do
        line(v.x * 32 + 64, v.y* 32 + 64, 7)
    end
    for x=0,128 do
        for y=0,128 do
           if point_in_polygon(polygon.vertex_list, {x=x,y=y}) then
                pset(x,y,7)
           end
        end
    end
end

function subdraw()
    cls()
    for face in all(cubeFaces) do
        fillPolygon(face)
    end
    -- fillPolygon(cubeFaces[1])
end