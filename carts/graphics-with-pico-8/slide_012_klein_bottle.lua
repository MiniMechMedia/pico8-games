
function init()
    dl=.0024415
    x=-.3626
    y=0
    r=.05
    mesh={}
    i=0

    for j=0,4427 do
        l=j\9*dl-.7789
        a=(l)^2-.1068
        tx=cos(a)
        ty=sin(a)
        if (j\9%41<1) then
            theta=j%9/8
            o=sin(theta)
            i+=1
            mesh[i]={
                x=x-r*o*ty,
                y=y+r*o*tx,
                z=r*cos(theta)
            }
            bodyradius=r-y
            mesh[i+108]={
                x=-x,
                y=bodyradius*o,
                z=bodyradius*cos(theta)
            }
        end
        x+=tx*dl/9
        y+=ty*dl/9
    end
end

function draw()
    for i=0,441do
    sliceindexbase=i%25*9
    sliceoffset=i\25
        p=mesh[sliceindexbase+sliceoffset+1]or mesh[9-sliceoffset]
        if(i>225)p=mesh[i-225]
        a=t()/9
        line((p.z*sin(a)+cos(a)*cos(a)*p.x-cos(a)*sin(a)*p.y)*100+64,(sin(a)*p.x+cos(a)*p.y)*100+64,7)
    end
end
