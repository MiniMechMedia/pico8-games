
function draw()
    SCALE = 32
    OFFSET = 64
    
    local objects = {
        gameObject({
            {x = -1.5, y = 1.5},
            {x = -1.5, y = -1.5},
            {x = 1.5, y = -1.5},
            {x = 1.5, y = 1.5}
        }),
        gameObject({
            {x = 0, y = .5},
            {x = 0, y = -.5},
            {x = 1, y = -.5},
            {x = 1, y = .5}
        })
    }

    for obj in all(objects) do
        for vertex in all(obj.mesh) do
            screen_x = vertex.x * SCALE + OFFSET
            screen_y = vertex.y * SCALE + OFFSET
            line(screen_x, screen_y)
        end
                                                                    line()
    end
end
