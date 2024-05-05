-- The point is we show sides intersecting sorta
function init()
    objects = {
        gameObject(unit_cube_mesh,
            {
                rot={x=0, y=0.05, z=0.1},
                pos = {x=0,y=0,z=2.5},
                scale=.5
            }
        ),
    }

    for index, face in ipairs(objects[1].mesh) do
        -- face.color = index
        face.color = ({
            4,
            14,
            3,
            11,
            12,
            8
        })[index]
        -- assert(face.color != nil)
    end
end

function draw()
    -- c = 2
    for obj in all(objects) do
        -- obj.rot = {x=time()/10, y=time()/10, z=0.1}
        -- for ind, face in ipairs(obj.mesh) do
        for face in all(obj.mesh) do
            fill_polygon(face, obj)
            
            
            -- for vertex in all(screen_coords) do
            --     line(vertex.x, vertex.y, 7)
            -- end
        -- for n in all(normals) do
            -- for i=1,4 do
            --     v = face[i]
            --     n = normals[i]
            --     line(v.x,v.y, v.x+n.x,v.y+n.y)
            -- end
        end
    end
end
