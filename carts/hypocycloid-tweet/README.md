# Hypocycloid Tweet
[Hypocycloids](https://en.wikipedia.org/wiki/Hypocycloid) are curves that 
are formed similarly to using a [Spirograph](https://en.wikipedia.org/wiki/Spirograph) toy
An interesting property they have is that a hypocycloid with n cusps (the pointy parts) 
can move around inside a hypocycloid with n+1 cusps and maintain contact between the inner
cusps and the outer curve.
<a href="https://johncarlosbaez.wordpress.com/2013/12/03/rolling-hypocycloids/"><cite>https://johncarlosbaez.wordpress.com/2013/12/03/rolling-hypocycloids</cite></a>


[![alt](images/cover.png)](https://minimechmedia.itch.io/hypocycloid-tweet)


Play it now on [itch.io](https://minimechmedia.itch.io/hypocycloid-tweet) or remix it on [pico-8-edu.com](https://pico-8-edu.com/?c=AHB4YQHIAUbrweEv8QIvcHdT3N9cf-ryKzzE9UHSGHwPccwt1xTJ1kLwBvEjFGXTDmyYoM-uTy3xDl1QFi8xs9LVxUa6EpUWeISoyl-iEbyRNEGbn3dWYLidkXwlUhARENEPCrq4qq7b6SfKlbrNXyIKmirLsirL2qypskqVPKUq0T1C4xkKwhOLvIuKqOh3oqGqiKK8GgkeoQiStCvPuqt6iLgfHKxW5rJiJU1XjivNsWaOd9hZSofifq64Li2aJt4IN9uNzTY7bmmkH7kuirIsy8phP0z5JfCbZki20yZTEyOaAh4QDVkcyPp_a2HmwJ06n5ioJ_oJtyP21oiVjGWlgYUsa6Iu2aiiKBkIs7DwiRmCponSwcWhZm-lwrptmwvrpIpt1I9sGDOIp-bq6spuJ4zymbHZuc1icHOg31kYdoabZis=)


This cart is tweetable at just 272 characters.

```lua
c=cos
s=sin
l=line
::_::
cls()
k=-10
a = t()/20
::h::
for i=1.1,0,.1/k do
x=k*c(i)+c(k*i)
y=k*s(i)+s(k*i)
for k2=k-1,-10,-1 do
mx=c(a+.5/k2)
my=s(a+.5/k2)
ax=c(a*k2)
ay=s(a*k2)
x,y=x*mx-y*my+ax,x*my+y*mx+ay
end
l(6*x+64,6*y+64,6-k)
end
l()
if(k<-2)k+=1goto h
flip()
goto _
```

## Explanation
```lua
c=cos
s=sin
l=line
::_::
cls()
-- abs(k) is the number of cusps the hypocycloid will have
-- we will draw nested hypocycloids with 10, 9, ..., 3 cusps
k=-10
-- This is the phase of the transformation that we apply to
-- animate the hypocycloids
a = t()/20
::draw_hypocycloid::
-- Sweep through a full revolution (PICO-8 uses a convention of 
-- 0-1 instead of 0-2pi for angles)
-- Use a dynamic step size to balance performance with quality
for i=1.1,0,.1/k do
    -- (x,y) is now the point on a k-cusped hypocycloid at angle i
    x=k*c(i)+c(k*i)
    y=k*s(i)+s(k*i)
    -- Time to apply the transformation to make this hypocycloid
    -- nest within the previous one.
    -- Transformation consists of rotating the hypocycloid as
    -- well as translating the center of the hypocycloid around
    -- the unit circle.
    -- And this transformation needs to be iteratively applied
    -- for every outer hypocycloid. There is probably a more
    -- efficient way to do this, but just recalculate the transformation
    -- for every hypocycloid
    for k2=k-1,-10,-1 do
        -- Calculate the rotation portion
        -- The .5 is needed to ensure the cusps of all hypocycloids align
        mx=c(a+.5/k2)
        my=s(a+.5/k2)
        -- Calculate the translation portion
        ax=c(a*k2)
        ay=s(a*k2)
        -- Apply the transformation
        x,y=x*mx-y*my+ax,x*my+y*mx+ay
    end
    l(6*x+64,6*y+64,6-k)
end
l()
if(k<-2)k+=1goto draw_hypocycloid
flip()
goto _
```





## About




Source code available on [GitHub](https://github.com/MiniMechMedia/pico8-games/tree/master/carts/hypocycloid-tweet)


## Acknowledgements
Based on this [animation by Greg Egan](https://commons.wikimedia.org/wiki/File:Rolling_Hypocycloids.gif).  
See the [Azimuth blog](https://johncarlosbaez.wordpress.com/2013/12/03/rolling-hypocycloids/)
for more info

