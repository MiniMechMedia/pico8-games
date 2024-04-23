
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
                pos={x=0,y=0},
                rot=0.125
            }
        ),
        gameObject(unit_square_mesh,
            {
                scale={x=.5, y=.25},
                pos={x=.5,y=0},
                rot=0.125
            }
        )
    }

    for obj in all(objects) do
        for vertex in all(obj.mesh) do
            obj_x = vertex.x * cos(obj.rot) - vertex.y * sin(obj.rot)
            obj_y = vertex.x * sin(obj.rot) + vertex.y * cos(obj.rot)

            world_x = obj_x * obj.scale.x + obj.pos.x
            world_y = obj_y * obj.scale.y + obj.pos.y

            screen_x = world_x * SCALE + OFFSET
            screen_y = world_y * SCALE + OFFSET

            line(screen_x, screen_y)
        end
        line()
    end

end
