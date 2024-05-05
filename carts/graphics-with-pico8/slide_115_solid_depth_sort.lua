
function init()
    objects = {
        gameObject(unit_cube_mesh,
            {
                rot={x=0, y=0.05, z=0.1},
                scale=.25,
                pos = {x=0,y=0,z=3.5},
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

    -- function get_center_z(face)
    --     return face.center.z
    -- end
end



function draw()
    -- c = 2
    for obj in all(objects) do
        obj.rot = {x=time()/5, y=.05+time()/2, z=0.1}

        -- get_center_z = function() return rnd() end
        -- for ind, face in ipairs(obj.mesh) do
        for face in all(sort(obj.mesh, function(face) 
                local _,_,z=obj:objToWorld(face.center)
                return z
            end)) do
                print(#face)
                -- assert(#face == 5)
                print(count_elements(face))


                fill_polygon(face, obj)
        end
    end
end
