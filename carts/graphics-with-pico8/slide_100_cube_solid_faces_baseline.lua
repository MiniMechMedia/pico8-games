
function draw()
    local objects = {
        gameObject(unit_cube_mesh,
            {
                rot={x=0, y=0.05, z=0.1},
            }
        ),
    }

    for obj in all(objects) do
        for face in all(obj.mesh) do
            for vertex in all(face) do
                local rotated = rotate(vertex, obj.rot)
                local world_x, world_y, world_z = rotated.x, rotated.y, rotated.z

                local screen_x = world_x * SCALE + OFFSET
                local screen_y = world_y * SCALE + OFFSET

                line(screen_x, screen_y)
            end
            line()
        end
    end

end