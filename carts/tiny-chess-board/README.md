# Tiny Chess Board
Non-interactive low resolution chessboard


[![64x64 pixel chessboard with black and white squares and gray pieces](images/cover.png)](https://caterpillargames.itch.io/tiny-chess-board)


Play it now on [itch.io](https://caterpillargames.itch.io/tiny-chess-board) or remix it on [pico-8-edu.com](https://www.pico-8-edu.com/?c=AHB4YQD9ANcCAO5trQwlZqaFkWUmxexNDiStB4bFZobsTQGvJw1g9ZDt4iXOOf1cG7xBM92cEZ60GxRBUD1Al6zFVfASjxFclR0eJlPlatw4Ixq4-fR3uH7lCYJbFs5ZKpJzZprIA1VXKQgEJ92zdtPYYVGXl_lUqjMydlcQvsJMurfSDi3eflZTBNFjlDtlMVl0amI6A0UxZ_XGG9Vr9MevnaYlcH2qMDKSnSAnshss6hbY4LpCUDwr0wO7qmRaIcdNVV0nGDI88wIXBvcXwRO8w2BxXAU=&g=w-w-w-w1HQHw-w2Xw-w3Xw-w2HQH)


This cart is tweetable at just 253 characters.

<pre><code>poke(13-😐,3)for i=0,63do
x=i%8*8y=i\8*8r="\0*>、、>>>"n="▮8>>x||<"b="⁸▮⁘、⁸、、>"rectfill(x,y,x+8,y+8,(i+i\8+1)%2*7)if(y<1or i>55)print("\^."..({r,n,b,"⁘、⁸、、>>>","⁸、⁸、、>>>",b,n,r})[x/8+1],x,y,5)
if(y==8or y==48)print("\^.\0⁸、、⁸、、>",x,y-i\48,5)
end::_::goto _</code></pre>





## About
Created for [Pico-8 tiny cart jam](https://itch.io/jam/pico-8-tiny-cart-chaos-/entries)  
Jam Rules:  
  - Must use exactly 3 colors  
  - Maximum 300 characters  




Source code available on [GitHub](https://github.com/CaterpillarGames/pico8-games/tree/master/carts/tiny-chess-board)


## Acknowledgements
Piece sprites converted to one-off character codes using [Bitdraw!](https://www.lexaloffle.com/bbs/?pid=102723) tool by [CoffeeBat](https://www.lexaloffle.com/bbs/?uid=50382)  
A few characters saved by using [Constant Companion](https://www.lexaloffle.com/bbs/?tid=44801) tool by [pancelor](https://www.lexaloffle.com/bbs/?uid=27691)

