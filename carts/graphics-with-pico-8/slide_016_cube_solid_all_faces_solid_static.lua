
function init()
    objects = {
        gameObject(unit_cube_mesh,
            {
                scale=.8,
                pos={x=0, y=0, z=4},
                rot={x=0, y=0.08, z=0.1},
            }
        ),
    }

    for index, face in ipairs(objects[1].mesh) do
        face.color = ({
            4,      -- <a style="color: #AB5236"></a>
            14,     -- <a style="color: #FF77A8"></a>
            3,      -- <a style="color: #008751"></a>
            11,     -- <a style="color: #00E436"></a>
            12,     -- <a style="color: #29ADFF"></a>
            8,      -- <a style="color: #FF004D"></a>
        })[index]
    end
end

function draw()
    for obj in all(objects) do
        for face in all(obj.mesh) do
            fill_polygon(face, obj, face.color)
        end
    end
end
