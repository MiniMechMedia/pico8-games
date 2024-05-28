
function draw()
    local objects = {
        gameObject(unit_cube_mesh,
            {
                scale=.8,
                pos={x=0, y=0, z=4},
                rot={x=0, y=0.0, z=0.1},
            }
        ),
    }

    for obj in all(objects) do
        for face in all(obj.mesh) do
            for vertex in all(face) do
                screen_x, screen_y = obj:objToScreen(vertex)

                line(screen_x, screen_y)
            end
                                                                                                       line()
        end
    end
end
