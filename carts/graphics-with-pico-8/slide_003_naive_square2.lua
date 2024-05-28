
function draw()
    local vertices = {
        {x = 32, y = 96},
        {x = 32, y = 32},
        {x = 96, y = 32},
        {x = 96, y = 96}
    }

    for vertex in all(vertices) do
        line(vertex.x, vertex.y)
    end
end
