# Galton Board Tweet
[Galton Board](https://en.wikipedia.org/wiki/Galton_board) simulator tweet cart


[![Pixel rendering of sand falling down pegs and accumulating in the shape of a normal curve](images/cover.png)](https://minimechmedia.itch.io/galton-board-tweet)


Play it now on [itch.io](https://minimechmedia.itch.io/galton-board-tweet) or remix it on [pico-8-edu.com](https://pico-8-edu.com/?c=AHB4YQHOAWnrwd0nH-8ID-AAu3c32RucXnXvcHyQNAbXOxxzyzVFsrUQvMELLBRl097-Aibos4XUEs-QBWXxEM_w09XFRqohYIGhIqkfYskbSROU9XlnBYab2dhaiRREBET0g4Iurqrr1AeyjTRsx6KgqRayrMqyMmuqrFIlG1IlClSJzlEaz1AQXvgWrzHQrL1EsnfcxkNERTcX7CwF71AEUXVaclh8Zn1c13ZtWU1UO1GkEzASNo8SZeXoWtYceGaRFGcOJVemcWjZDUsEa6em4UhZLmy8QvcOWyaZHV0cj-qB-jGikeYAD1zgg7Qqpi7I6mrz5NvfYHnHJVJBo6OT44M7_YqAyMapAwcsHtHspOOTcZlNTdRRVEe6BNG9WgXhxtLaiFLAah1PhIIhuazAuXvVyExxwW5TFYVS2PQJm5t3zOyvhz6JmxMWFsbWlzYHy26k3Cu78QknyY_lg81QNhVno8XKMg==)


This cart is tweetable at just 278 characters.

```lua
c={}i=0k=128f=fillp::_::if(i%k<1)flip()cls()i=0
f(&#9617;)line(i,9,i,70,5)f()line(i,k,i,k-@i,15)
c[i]=c[i]or{x=-k,y=0,v=0,w=0,r=rnd,o=_ENV}
_ENV=c[i]pset(x,y,15)w+=.1g=r(8)x+=v
y+=w
if(y>128)poke(x,@x+1)x,y,v,w=60+g,g/5,0,0
if(y>9and y<70and g<2)v=cos(g)/2w=sin(g)/2
_ENV=o
i+=1goto _
```

## Explanation
```lua
c={}
i=0
k=128
f=fillp
::_::if(i%k<1)flip()cls()i=0
f(&#9617;)line(i,9,i,70,5)f()line(i,k,i,k-@i,15)
c[i]=c[i]or{x=-k,y=0,v=0,w=0,r=rnd,o=_ENV}
_ENV=c[i]pset(x,y,15)w+=.1g=r(8)x+=v
y+=w
if(y>128)poke(x,@x+1)x,y,v,w=60+g,g/5,0,0
if(y>9and y<70and g<2)v=cos(g)/2w=sin(g)/2
_ENV=o
i+=1goto _
```





## About




Source code available on [GitHub](https://github.com/MiniMechMedia/pico8-games/tree/master/carts/galton-board-tweet)

