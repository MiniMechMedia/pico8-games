
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

local cubeFaces = {
    polygon({vec3(-1,-1,-1), vec3(-1,1,-1), vec3(1,1,-1), vec3(1,-1,-1)})
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
end

function subdraw()
    cls()
    fillPolygon(cubeFaces[1])
end