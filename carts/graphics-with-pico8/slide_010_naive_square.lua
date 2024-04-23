

function draw()
    local vertices = {
        {-1, 1},
        {-1, -1},
        {1, -1},
        {1, 1}
    }

    for vertex in all(vertices) do
        line(vertex[1], vertex[2])
    end
end

