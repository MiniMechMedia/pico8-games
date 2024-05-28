

function draw()
    local vertices = {
        {x = -1, y = 1},
        {x = -1, y = -1},
        {x = 1, y = -1},
        {x = 1, y = 1}
    }

    for vertex in all(vertices) do
        line(vertex.x, vertex.y)
    end
end
