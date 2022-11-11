# Simon Says Tweet
Watch the sequence of lights and then repeat it. If you get it right, the sequence will get longer. If you get it wrong, the game will start over.


[![A disk divided into four sectors of different colors, with the blue sector lit up](images/cover.png)](https://minimechmedia.itch.io/simon-says-tweet)


Play it now on [itch.io](https://minimechmedia.itch.io/simon-says-tweet) or remix it on [pico-8-edu.com](https://www.pico-8-edu.com/?c=AHB4YQEUAO6nBE9QBFff8xaHnHBHcUhxyGu8Q3hDcH1SPUJS1cHZRXD6CzzDKbec-wozd4TxyMZNQ_Hm_V10eXn7Tj4QvsMzDEXRRjB0V5DHvUTIIzRbI3sz14kEvELW3b90nBduq5PmuOuadHFq6A2G7ks3LFS3I-f1i6PpypYZm743i6SIooDYQDGyE583fWT-BuXsdjAYTMwFm7sDA4vx7ogjZtZXNrYGiyYobpwPtQjESYLFmZlZjywMrrTTo9XORCxRsDe8HFW6BgdG2X1x0zzC7Hoxv79hjLa0g9KpfkGjKjBSjox0EkEXAA==&g=w-w-w-w1HQHw-w2Xw-w3Xw-w2HQH)


This cart is tweetable at just 276 characters.

<pre><code>::r::d={3,1,2,0}u=''i=0p=u::_::cls()for c=1,4do
b=d[c]if(btnp(b))u..=c
for j=0,318do
k=j\4/318+c/4-5/8line(64,64,64+50*cos(k),64+50*sin(k),(btn(b)or i\15%2>0and''..c==p[i\30])and({12,8,11,9})[c]or c)end
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

