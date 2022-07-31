# Skyline Tweet
Simple tweet cart that generates a scrolling city skyline


[![Black rectangles with white dots on blue background approximating a city skyline](images/cover.png)](https://caterpillargames.itch.io/skyline-tweet)


Play it now on [itch.io](https://caterpillargames.itch.io/skyline-tweet) or remix it on [pico-8-edu.com](https://www.pico-8-edu.com/?c=AHB4YQEVAMgvcc4bPMDd62fccc0FI7enNkgOv-8R0jTMbgruLoLkBY4v0jfYSC96ibOSoD7IRokNRmzQ1y-wAJdoh0TFcUV3Vdo8w9LIWLy70W0VOwNrM1l1lbtmFjais4rDoqHGAhPZwMRE3ixGYytLG4PBiJZAPlTkRZJ7XiueEhgIX6FeeAk9gWpnTTsgrZJiI9zYkh1P3w_1-WnaBOKD2eDm0E66uLBRXNf2rdSIR3TKNyZULttoEu4sTfVxGD7CSl-srAI=&g=w-w-w-w1HQHw-w2Xw-w3Xw-w2HQH)


This cart is tweetable at just 277 characters.

<pre><code>y=rnd(128)
h=128
cls(1)
::_::
memcpy(0x6001,0x6000,0x2000)
if rnd() < 0.1 then
	y = mid(y + rnd(60) - 30, 0, h)
end
rectfill(0,0,1,h,1)
rectfill(0,y,1,h,0)
for w = y+2, h, 2 do
	if rnd() < (h-y)/600 then
		pset(x,w,7)
	end
end
if rnd() < 0.01 then
	y = rnd(h)
end
flip()
goto _</code></pre>





## About




Source code available on [GitHub](https://github.com/CaterpillarGames/pico8-games/tree/master/carts/skyline-tweet)

