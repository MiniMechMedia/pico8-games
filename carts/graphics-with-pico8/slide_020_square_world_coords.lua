
function draw()
    SCALE = 32
    OFFSET = 64
    
    local vertices = {
        {x = -1, y = 1},
        {x = -1, y = -1},
        {x = 1, y = -1},
        {x = 1, y = 1}
    }

    for _, vertex in ipairs(vertices) do
        line(vertex.x * SCALE + OFFSET,
             vertex.y * SCALE + OFFSET)
    end
end
