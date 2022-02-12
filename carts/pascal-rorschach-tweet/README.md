# Pascal-Rorschach Tweet
This cart calculates successive rows of Pascal's Triangle 
in binary (and then mirrors the result vertically for more viewing potential). 
This results in some surprisingly discernible images...or
maybe I've just been looking at pixel art too much.

This cart is tweetable at just 274 characters

```
cls()
poke(0x5f2c,6)
n=0
pset(63,0,7)
::_::
if (btnp(4)) printh(n,'@clip')
if btnp(5) then
  n+=1
  for x=0,127 do
    c=0
    for y=0,63 do
      a=pget(x,y)
      b=pget(x-1,y)
      pset(x,y+64,a^^b^^c)
      c=a&b|a&c|b&c
    end
  end
  memcpy(0x6000,0x7000+(n%4)\3,0x1000)
end
flip()
goto _
```

[![Pixel art of a little girl with wings](screenshots/cover.png)](https://caterpillargames.itch.io/pascal-rorschach-tweet)

Play it now on [itch.io](https://caterpillargames.itch.io/pascal-rorschach-tweet)

## Controls
* X - Calculate next generation
* Z - Copy current generation number to clipboard (i.e. how many times you have pressed the X key)




## About


Source Code: On [GitHub](https://github.com/CaterpillarGames/pico8-games/tree/master/carts/pascal-rorschach-tweet)

## Acknowledgements
Inspired by [this animation](https://en.wikipedia.org/wiki/Pascal%27s_triangle#/media/File:Pascal's_Triangle_animated_binary_rows.gif)
on the Pascal's Triangle [Wikipedia page](https://en.wikipedia.org/wiki/Pascal%27s_triangle)


