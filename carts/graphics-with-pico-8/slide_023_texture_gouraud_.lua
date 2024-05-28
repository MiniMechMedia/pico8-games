function init()

    objects = {
        gameObject(unit_cube_mesh,
            {
                scale=.8,
                pos={x=0, y=0, z=4},
                rot={x=0, y=0.06, z=0.1},
            }
        ),
    }
    light = {x=0,y=0,z=-1}

    light_gray_map = {
        -- 0,       -- <a style="color: #000000"></a>
        128,     -- <a style="color: #291814"></a>
        133,     -- <a style="color: #49333B"></a>
        5,       -- <a style="color: #5F574F"></a>
        6,       -- <a style="color: #C2C3C7"></a>
        6,       -- <a style="color: #C2C3C7"></a>
    }

    dark_gray_map = {
        0,       -- <a style="color: #000000"></a>
        128,     -- <a style="color: #291814"></a>
        128,     -- <a style="color: #291814"></a>
        133,     -- <a style="color: #49333B"></a>
        5,       -- <a style="color: #5F574F"></a>
        5,       -- <a style="color: #5F574F"></a>
    }

    pink_map = {
        1,       -- <a style="color: #1D2B53"></a>
        2,       -- <a style="color: #7E2553"></a>
        2,       -- <a style="color: #7E2553"></a>
        4,       -- <a style="color: #AB5236"></a>
        14,      -- <a style="color: #FF77A8"></a>
        14,      -- <a style="color: #FF77A8"></a>
    }

    composite_map = {
        [5] = dark_gray_map,
        [6] = light_gray_map,
        [14] = pink_map
    }
end

function draw()
    for obj in all(objects) do
        obj.rot = {x=time()/8, y=.05+time()/4, z=0.1}
        for face in sort_faces(obj.mesh, obj) do
            for vertex in all(face) do
                local rotated = obj:objToRotated(vertex)
                vertex.intensity = rotated.x * light.x + rotated.y * light.y + rotated.z * light.z
            end
            local start_x, start_y, start_z = obj:objToWorld(face[1])
            -- calculate basis vectors
            local ux, uy, uz = obj:objToWorld(face[2])
            ux -= start_x
            uy -= start_y
            uz -= start_z
            
            local vx, vy, vz = obj:objToWorld(face[4])
            vx -= start_x
            vy -= start_y
            vz -= start_z

            for i = 0,1,0.03 do
                for j = 0,1,0.03 do
                    local surface_vector = {
                        x = start_x + ux*i + vx*j,
                        y = start_y + uy*i + vy*j,
                        z = start_z + uz*i + vz*j,
                    }
                    
                    local color = sget(j*30,i*30)
                    local sx, sy = obj:worldToScreen(surface_vector)

                    local light_map = composite_map[color]
                    local avgIntensity = (
                        face[1].intensity * (1-i) * (1-j) +
                        face[2].intensity * i * (1-j) +
                        face[3].intensity * i * j +
                        face[4].intensity * (1-i) * j
                    )
                    local index = mid(1,avgIntensity*#light_map\1+1,#light_map)
                    color = light_map[index]
                    
                    pset(sx, sy, color)                                                                  pset(sx+1, sy, color)pset(sx+1, sy+1, color)pset(sx, sy+1, color)
                end
            end
        end
    end
end