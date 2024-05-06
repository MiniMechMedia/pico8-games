

unit_sphere_mesh = {}

mod = 20

for i=0,mod do
    for j=0,mod do
        local ip = (i+1) 
        local jp = (j+1) 
        -- i,j,ip,jp = i/mod,j/mod,ip/mod,jp/mod
        local c=sin(i/mod)
        local cp=sin(ip/mod)
        add(unit_sphere_mesh, {
            {x=c*cos(j/mod),y=c*sin(j/mod),z=cos(i/mod)},
            {x=c*cos(jp/mod),y=c*sin(jp/mod),z=cos(i/mod)},
            {x=cp*cos(jp/mod),y=cp*sin(jp/mod),z=cos(ip/mod)},
            {x=cp*cos(j/mod),y=cp*sin(j/mod),z=cos(ip/mod)},
            normal = {x=c*cos(j/mod),y=c*sin(j/mod),z=cos(i/mod)}
        })
    end
end
-- q={}for i=0,1,.05do
-- for j=0,1,.05do
-- c=sin(i)add(q,{x=c*cos(j),y=sin(j)*c,z=cos(i)})end
-- end
-- color(7)s=.0125

function init()
    objects = {
        gameObject(unit_sphere_mesh,
        -- gameObject(unit_cube_mesh,
            {
                rot={x=0, y=0.05, z=0.1},
                pos={x=0, y=0, z=5},
                scale=.9
            }
        ),
    }
    local ang = .3
    light = {x=cos(ang),y=0,z=sin(ang)}


    light_map = {
        -- 0,
        128,
        133,
        -- 1,
    
        -- 1,
        5,
        -- 13,
        6,
        7
    }
    
    extras = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}
    for val in all(light_map) do
        if val < 128 then
            del(extras, val)
        end
    end
    
    for i, val in ipairs(light_map) do
        if val >= 128 then
            local e = extras[1]
            deli(extras, 1)
            light_map[i] = e
            pal(e,val,1)
        end
    end

end

function draw()
    -- for i, v in ipairs(light_map) do
    --     pal(i,v,1)
    -- end
    -- c = 2
    for obj in sort_objects(objects) do
        -- obj.rot = {x=time()/10/2, y=time()/5/2, z=time()/9/2}
        light = {x=cos(time()/10),y=0,z=sin(time()/10)}

        -- get_center_z = function() return rnd() end
        -- for ind, face in ipairs(obj.mesh) do
        for face in sort_faces(obj.mesh, obj) do
            -- local nx,ny,nz=obj:objToWorld(face.normal)
            local n = rotate(face.normal, obj.rot)
            local dot = light.x*n.x + light.y*n.y + light.z*n.z
            -- dot = abs(dot)*6

            local proto_index = (dot*#light_map+.5)\1
            index = mid(1, proto_index, #light_map)
            local col = light_map[index]
            -- col=13+128
            fill_polygon(face, obj, col)
            -- for vertex in all(face) do
            --     local sx, sy = obj:objToScreen(vertex)
            --     -- line(sx, sy)
            -- end
            -- line()
            -- print(dot, 50,50,7)
            -- print(dot*#light_map, 40,40,7)
            -- print(color, 64,64,7)
            -- color(7)
            -- print(n.x, 5,40)
            -- print(n.y)
            -- print(n.z)
            -- print(dot*#light_map\1)


            -- break
        end
    end
end