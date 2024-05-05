
function init()
    objects = {
        gameObject(unit_cube_mesh,
            {
                rot={x=0, y=0.05, z=0.1},
                scale=.5
            }
        ),
    }

    for index, face in ipairs(objects[1].mesh) do
        -- face.color = index
        face.color = ({
            3,
            8,
            12,
            11,
            14,
            4
        })[index]
        -- assert(face.color != nil)
    end
end


function draw()
    -- c = 2
    for obj in all(sort(objects, function(obj)
        return obj.pos.z
    end)) do
        obj.rot = {x=time()/10, y=time()/10, z=0.1}
        -- get_center_z = function() return rnd() end
        -- for ind, face in ipairs(obj.mesh) do
        for face in all(sort(obj.mesh, function(face) 
                local _,_,z=obj:objToWorld(face.center)
                return z
            end, 3)) do
                -- assert(false)
                fill_polygon(face, obj, 8)
        end
    end
end