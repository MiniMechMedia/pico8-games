# Galton Board Tweet
[Galton Board](https://en.wikipedia.org/wiki/Galton_board) simulator tweet cart


[![Pixel rendering of sand falling down pegs and accumulating in the shape of a normal curve](images/cover.png)](https://minimechmedia.itch.io/galton-board-tweet)


Play it now on [itch.io](https://minimechmedia.itch.io/galton-board-tweet) or remix it on [pico-8-edu.com](https://pico-8-edu.com/?c=AHB4YQEzAQjrwVscdtN5h93ngdeYMEN1553n3XjmheWFUZoGVx83EN3eXHR9ctNRp50eFd35wRPcF9xdBFF1VHJSfGJ9Vtd2bVlNVK8QRToBI2HzKFFWvsH9WXPdlUVSXDmUHJnGoWU3LBEMX5qGI2W5sHF4d-qWSR7hGRbfIuoH_seIRpq38MBj_CCtiqlXyOpq84Dp45d3XCIVNDo6_RaDO-mKgMjGsQPXLr5Ds5OOT8ZlNjVRR1Ed6RJER2sVhBtLayNKAat1PBEKhuSyAjfvVSMzxcW7TVUUSmHTz7C5eevM-nrok7g5YWFhbH1pc7DsRsq9shufcJL8WDrYDGVTcTZarCwD&g=w-w-w-w1HQHw-w2Xw-w3Xw-w2HQH)


This cart is tweetable at just 278 characters.

<pre><code>c={}i=0k=128f=fillp::_::if(i%k<1)flip()cls()i=0
f(░)line(i,9,i,70,5)f()line(i,k,i,k-@i,15)
c[i]=c[i]or{x=-k,y=0,v=0,w=0,r=rnd,o=_ENV}
_ENV=c[i]pset(x,y,15)w+=.1g=r(8)x+=v
y+=w
if(y>128)poke(x,@x+1)x,y,v,w=60+g,g/5,0,0
if(y>9and y<70and g<2)v=cos(g)/2w=sin(g)/2
_ENV=o
i+=1goto _</code></pre>





## About




Source code available on [GitHub](https://github.com/CaterpillarGames/pico8-games/tree/master/carts/galton-board-tweet)

