
function init()
    objects = {
        gameObject(unit_cube_mesh,
            {
                rot={x=0, y=0.05, z=0.1},
                scale=.5
            }
        ),
    }
end


function draw()
    -- c = 2
    for obj in sort_objects(objects) do
        obj.rot = {x=time()/10, y=time()/10, z=0.1}
        -- get_center_z = function() return rnd() end
        -- for ind, face in ipairs(obj.mesh) do
        for face in sort_faces(face.mesh) do
            fill_polygon(face, obj)
        end
    end
end