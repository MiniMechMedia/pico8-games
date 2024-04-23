
function draw()
    local SCALE = 32
    local OFFSET = 64
    
    local objects = {
        gameObject({
            {x = -1.5, y = 1.5},
            {x = -1.5, y = -1.5},
            {x = 1.5, y = -1.5},
            {x = 1.5, y = 1.5}
        }),
        gameObject({
            {x = 0, y = .25},
            {x = 0, y = -.25},
            {x = 1, y = -.25},
            {x = 1, y = .25}
        })
    }

    for obj in all(objects) do
        for vertex in all(obj.mesh) do
            line(vertex.x * SCALE + OFFSET, vertex.y * SCALE + OFFSET)
        end
        line()
    end

end
