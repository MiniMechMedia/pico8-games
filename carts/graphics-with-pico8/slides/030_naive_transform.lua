
function draw()
    local objects = {
        {
        {-1, 1},
        {-1, -1},
        {1, -1},
        {1, 1}
        },
        {
            {0, 1},
            {0, -1},
            {1, -1},
            {1, 1}
        }
    }

    for object in all(objects) do
        for vertex in all(object) do
        line(vertex[1] * 32 + 64, vertex[2] * 32 + 64)
    end
end
