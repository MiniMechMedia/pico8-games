
function init()
    objects = {
        gameObject(unit_square_mesh,
            {
                scale=.8,
                pos={x=0, y=0, z=4},
                rot={x=0, y=0.0, z=0.1},
            }
        ),
    }
end

function draw()
    for obj in all(objects) do
        for face in all(obj.mesh) do
 
            local start_x, start_y, start_z = obj:objToWorld(face[1])
            -- calculate basis vectors
            local vx, vy, vz = obj:objToWorld(face[2])
            vx -= start_x
            vy -= start_y
            vz -= start_z
            assert(face[4] != nil)
            local ux, uy, uz = obj:objToWorld(face[4])
            ux -= start_x
            uy -= start_y
            uz -= start_z

            for i = 0,1,0.02 do
                for j = 0,1,0.02 do
                    local surface_vector = {
                        x = start_x + ux*i + vx*j,
                        y = start_y + uy*i + vy*j,
                        z = start_z + uz*i + vz*j,
                    }
                    local sx, sy = obj:worldToScreen(surface_vector)
                    pset(sx, sy, 7)
                end
            end
        end
    end
end
