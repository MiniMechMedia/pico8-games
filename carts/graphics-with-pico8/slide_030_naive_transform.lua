
function draw()
    local SCALE = 32
    local OFFSET = 64
    local objects = {
        gameObject({
            {x = -1, y = 1},
            {x = -1, y = -1},
            {x = 1, y = -1},
            {x = 1, y = 1}
        }),
        gameObject({
            {x = 1.5, y = 1.25},
            {x = 1.25, y = 1.25},
            {x = 1.25, y = 1.5},
            {x = 1.5, y = 1.5},
        })
    }

    for obj in all(objects) do
        for vertex in all(obj.mesh) do
            line(vertex.x * SCALE + OFFSET, vertex.y * SCALE + OFFSET)
        end
        line()
    end

end
