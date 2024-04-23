

function draw()
    local vertices = {
        {-1, 1},
        {-1, -1},
        {1, -1},
        {1, 1}
    }

    for vertex in all(vertices) do
        line(vertex[1] * 32 + 64, vertex[2] * 32 + 64)
    end
end
