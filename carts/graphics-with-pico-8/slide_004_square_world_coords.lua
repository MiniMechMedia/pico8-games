
function draw()
    SCALE = 32
    OFFSET = 64
    
    local vertices = {
        {x = -1, y = 1},
        {x = -1, y = -1},
        {x = 1, y = -1},
        {x = 1, y = 1}
    }

    for vertex in all(vertices) do
        screen_x = vertex.x * SCALE + OFFSET
        screen_y = vertex.y * SCALE + OFFSET
        line(screen_x, screen_y)
    end
end
