
function draw()
    local SCALE = 32
    local OFFSET = 64

    unit_square_mesh = {
        {x = -1, y = 1},
        {x = -1, y = -1},
        {x = 1, y = -1},
        {x = 1, y = 1}
    }

    local objects = {
        gameObject(unit_square_mesh,
            {
                scale={x=1.5, y=1.5},
                pos={x=0,y=0}
            }
        ),
        gameObject(unit_square_mesh,
            {
                scale={x=.5, y=.25},
                pos={x=.5,y=0}
            }
        )
    }

    for obj in all(objects) do
        for vertex in all(obj.mesh) do
            world_x = vertex.x * obj.scale.x + obj.pos.x
            world_y = vertex.y * obj.scale.y + obj.pos.y

            screen_x = world_x * SCALE + OFFSET
            screen_y = world_y * SCALE + OFFSET

            line(screen_x, screen_y)
        end
        line()
    end

end
