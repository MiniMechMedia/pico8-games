function init()
    for face in all(unit_cube_mesh) do
        local start = face[1]
        local ux, uy, uz = face[2].x-start.x, face[2].y-start.y, face[2].z-start.z
        local vx, vy, vz = face[4].x-start.x, face[4].y-start.y, face[4].z-start.z
        -- cross product
        face.norma1 = {                                                                                         -- yes this is intentionally a typo. Here's the thing, the cross product is coming out the wrong sign for some faces. I don't want to fix it. So just use the precomputed normals from earlier.
            x = uy * vz - uz * vy,
            y = uz * vx - ux * vz,
            z = ux * vy - uy * vx
        }
    end

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

    light_map = {
        128,     -- <a style="color: #291814"></a>
        133,     -- <a style="color: #49333B"></a>
        5,       -- <a style="color: #5F574F"></a>
        6,       -- <a style="color: #C2C3C7"></a>
        7,        -- <a style="color: #FFF1E8"></a>
        7,        -- <a style="color: #FFF1E8"></a>
    }

end

function draw()
    for obj in all(objects) do
        obj.rot = {x=time()/8, y=.05+time()/4, z=0.1}
        for face in sort_faces(obj.mesh, obj) do
            local n = rotate(face.normal, obj.rot)
            local dot = light.x*n.x + light.y*n.y + light.z*n.z

            local index = mid(1,dot*#light_map\1,#light_map)
            face.color = light_map[index]
            fill_polygon(face, obj, face.color)
        end
    end
end
