# Galaxy Tweet
A galaxy simulation inspired by [https://en.wikipedia.org/wiki/Density_wave_theory](Density Wave Theory).


[![Low resolution spiral galxy](images/cover.png)](https://caterpillargames.itch.io/galaxy-tweet)


Play it now on [itch.io](https://caterpillargames.itch.io/galaxy-tweet) or remix it on [pico-8-edu.com](https://www.pico-8-edu.com/?c=AHB4YQEVALunBPcWQXzz8W_wPl81b3D1Axzug9NfoFo-vzisOOeUJDknSMqwXnuC-vpH2OjdEZ902MqAkQ9L6nRlQDB8nWJguiEXctdIKR7QRFedVbUjS5YKd64qVlaiNBm5qr6qqBSCHkJtIGn2xrbK3A0v4Za8GztsJYqKcG-LVApEp51WTRQLrpAKWVQSqVOBkGRlMfO24cxQCQUniXbJW0w2DtfCXpLMvUYpYbg6EUsgvMHSXJEPAw==&g=w-w-w-w1HQHw-w2Xw-w3Xw-w2HQH)


This cart is tweetable at just 277 characters.

<pre><code>::_::
cls()
srand()
for i = 1, 100 do
	pset(rnd(128),rnd(128),7)
end
for i = 1, 1800 do
	r=rnd(50)
	p=r/30
	a=rnd() - t()/(2+r*r/50)
	x = r*cos(a)
	y = r *1.3 * sin(a)
	pset(64 + x * cos(p) - y*sin(p), 64 + x * sin(p) + y * cos(p), rnd({7,7,7,7,7,7,7,15,10}))
end
flip()
goto _</code></pre>





## About




Source code available on [GitHub](https://github.com/CaterpillarGames/pico8-games/tree/master/carts/galaxy-tweet)

