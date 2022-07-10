# Simon Says Tweet
Watch the sequence of lights and then repeat it. If you get it right, the sequence will get longer. If you get it wrong, the game will start over.


[![A disk divided into four sectors of different colors, with the blue sector lit up](images/cover.png)](https://caterpillargames.itch.io/simon-says-tweet)


Play it now on [itch.io](https://caterpillargames.itch.io/simon-says-tweet) or remix it on [pico-8-edu.com](https://www.pico-8-edu.com/?c=AHB4YQEYAO_nBE9QBFff8xaHnHBHcUhxyGu8Q3hDcH1SPUJS1cHZRXD6CzzDKbec-wozd4TxyMZNQ_Hm_V10eXn7Tj4QvsMzDEXRRjB0V5DHvUTIIzRbI_cdpxHwClV2-9B1XXdcHFXXndccODk19AZDcTphobrdOLAfHE1npszY9L1ZBEX0BKQGipXJ_L7pI-s3KGe3g8FgYi-oFydHNpdGRtYHovGdwBfh-NBMtlg0QTE6H_oRCJQEk0NDux5ZWNxpl1ermYlYpkA6LOsPXIrua5vmEVbHi-0DJoyRl3ZQO9UwaFQFNsqNvpMI2gI=&g=w-w-w-w1HQHw-w2Xw-w3Xw-w2HQH)


This cart is tweetable at just 280 characters.

<pre><code>::r::d={3,1,2,0}u=''i=0p=u::_::cls()for c=1,4do
b=d[c]if(btnp(b))u..=c
for j=0,96do
k=j\4/96+c/4-5/8line(64,64,64+50*cos(k),64+50*sin(k),(btn(b)or i\15%2>0and''..c==sub(p,i\30,_))and({12,8,11,9})[c]or c)end
end
i+=1flip()if(sub(p,1,#u)!=u)goto r
if(p==u)u=''i=0p..=rnd(d)+1
goto _</code></pre>


## Controls
* Arrow Keys - Activate a section of the board




## About




Source code available on [GitHub](https://github.com/CaterpillarGames/pico8-games/tree/master/carts/simon-says-tweet)


## Acknowledgements
Based on the game [Simon](https://en.wikipedia.org/wiki/Simon_(game)) by Hasbro

