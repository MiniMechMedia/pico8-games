

function draw()
    local vertices = {
        {32, 96},
        {32, 32},
        {96, 32},
        {96, 96}
    }

    for vertex in all(vertices) do
        line(vertex[1], vertex[2])
    end
end

