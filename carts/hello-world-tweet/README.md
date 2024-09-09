# Hello World Tweet
This program creates a heightmap (roughly) approximating the earth's surface by summing sinusoids.


[![A map resembling a simplified version of the Earth.](images/cover.png)](https://minimechmedia.itch.io/hello-world-tweet)

Leave a comment on [itch.io](https://minimechmedia.itch.io/hello-world-tweet)

This cart is tweetable at just 278 characters.

## Source
Remix it on [pico-8-edu.com](https://pico-8-edu.com/?c=AHB4YQHOAYnrweFnHx-cv-oOyRtEp1evkHVB0hh873DJIacUyVAePMEDvEFRNu39Eybos-NTSzxDF5TFQzzDSFcXG_lMVFrgEaIqf4hH8EbSBG1_3lmB4XZG8pVIQURARD8o6OKqum6nnyhX6jYfi4KmyrKsyrI2a6qsUiUqVYkCVaJzhMYzFKxdeM9dZ9161L2XXdp2o2c2Rw68QROdeHhz5enFeQfuHJ_1s8VGM3BlmZz7AEdWN1TZRDTTLPWHxzvDZVfdWiRjq944uAym6r7rTm2a7O6tZGVmoYmirmmW0nJhYXL1IVanymCyCPaf4djlifIRpm_44SFOKLt7qxPO8dvs8P7JQTg_ekIxMHXPVtdtdeMvkWXPYINjmjPWVlbu2cvqoXozSZbKjZcIy_mjB8aqmWzplOSkva1quoq7e8JwbbAO99q9Ip6o__TsYGqkNMHk5sLS0D1DpfDAUpukVTXSr0yohWysVANlPbs0cc-S1lxcLKQSBQOrtwyuLBaDi3kxuT4C)
```lua
w="+)G%K*C#+0?#;/_#?5S#7U7$'-W#/:/%#+3$+D[&31+$?3C$G-O#;8?$O9O$Ka3$+B##SC+$K2+$#M7#[D;#7[+#7:K$?9"
q=1::_::if(w[q])poke(q,ord(w[q])-35<<q%2*2)
x=q%128y=q\128h=0for i=1,89,8do
j=i+4h-=%i*sin(x*$i+sgn(25-i)*y*$j+%j>>14)>>13end
c=1if(h>1)c=5+2*sgn(y-53)
pset(x,y,c)q=1+q&8191goto _
```

## Explanation
Remix it on [pico-8-edu.com](https://pico-8-edu.com/?c=AHB4YRGsCRPrweFnHx-cv-oOyRtEp1evkHVB0hh873DJIacUyVAePMEDvEFRNu39Eybos-NTSzxDF5TlyEgUNXHyBOlG-Q5PYIqkCZ6hvu6qwHAzI-lCJB2iHCIcFHRxVR0306_UG3Wbj0RBU2VZVmVZmzVVVskRlXJEgRyR0MjGVpld1FVDZToWdStlU0gFJMcYp2qiZCMOmp2hSL_gmInaIi2zkSYe6cIwfYlkIe6EC9IoaqeyZijaaJYUy4p4YCh7hSIZ2AgGDlMRVgtQG9m7bKEcWEhX4oloIGxCyaGgWFqJBg7TEbhrKHmJ6rSij0ZcsHTalD6JKMlxm_FYPiBrIGawEc1Fu3PRRBLsNAvdTGkDXwxFU3NVUjWyBI2OQbwlZiRNXIapDsJWLKjwDm0bhgM6JupCbZJ0VTE2kDfy59BDiMqszftsxTS9FIqSQlgNioRpkSfJzdNFVR6WmgcLSTSgQZAkXTgUqRcuiI80Tin1WUa1DPomVzPoqz4MfDdVrwg9DAxsZFIlnuo2doIoGhAUGGlW6410IhzpN6IFtRShFukWkZEw78NUxmQjWSnCvm3M02mUr6nkJ6okaYSWFIn2srgs2rpMBQPVxn9IsKlBhp2MhCZEMCKuVkTyL0m3UPrEMrpngVh7VgQlysrwSBdSOSGl0LxoBouhKMqH7luTcxB5aGXDMsWHdEAiZqwZmJFFWBzSO8jEGrZWhmYWhFtSwYRQbaRSdxApkgraWB4pdoogNtAzdAZqAvssLW3E2my6VSPaDAI7G6XYUq2RUQ8kxU4xtDVRxzuV8uhGEaez8erc1k6kImyBwXigVWPV6hjpNWoCYYqRhbHIeUm2Io_dLEinqQsXs-FGkqg5bCUKqzoybbomAKd7uDZTD6gRVYnMknRF2ZQ6E64Y0NyY6naaoaKty3Ik6bWeRhTy0l46SIYq75ZWmlQYT70kqTfqLlFNmKgmBnTKFqsoi7uVSppP-CPMd7Q-ZqwSLQRRl1bak_IaEzuqQpIJEjBKHwrv2RjounpDJy49cm1Gi3MkX1hQYJMLaIfSLk7UNxc0FHVXBUul5ggnaGJDHD5VkdhAuCFU8JQnZyvVois0MAIaQRASnmBlQp6jaMO0MorMeoAmYEqNZqAMFCzS_B0WCq1alYxSLFAsSsweekp19hKxOofORieyMaMJUW300Ygmz1wyqhZbl61jCCBse0bHDYWC1Xz03WZUPSbGqsQ25dBeNKDPt5QkQxO5es6AekO91OWVNs5qWg5PKZOZIFb9l5bMnviTsjMohAUlYoSUA7GqwlSUiZbpfOsUNr00TpvHQ8VTSMItslqwhlwc1MFCMBjIkcszQVAEwkwzbVpWOYyFJjUwhBaF5t6Zgv9aWAjLNWVzSUbNTqTuqMOZ7cntQ-Ntvad_ceMpRrTbtBEGh3RXxOerPVmOTvFZ4Ea5pH1nv7ZbajKpPMGNpbE4UpePxI_qT1HM6a9ssU64mk4MZgjowrKlIpwblkWbK9os5JPwKHVl1hIbUcePDpU8Uq30ISwlyLBQXzAycuEBm5NHTg2O3djVtzanXnBDE1260pw6WRx6wBkzWXtJsdEMnFomm_9wa3VDlU1EM81SPxjvzJddNV8kY5PemC2DqbrvugOaJlveSlZmFpoo6ppmKS0XFiZH71idaspgsgjwPlz7QzHVhh-65htRN2z05TVPg2HqX9MnbO0EOh7aFIpc4Xpyx_rSxEuMT45O16uCHpvJfr-dLEjtiVKwkMgFyboC0w2t4CpGBWv-AIRQtCKspN91wwnhIYmOnIxYIqtzg3i4oqZRD7-Ef7JE_m6rWdKGG9PnWD_i3Wjdo5STTWjUZRu_mcgOKW8RN5H-uSUYOyK-o4CgIHwIyMJQ66OYGJGm0DYIYrFg8ZAhoAvptMV2w1oHTWJlsh7VRZeo4GB2yXS1MN1e0eVd9xI_QSyxpJe6GgrW1D8kLTZnICsojukqtJrQ_k_sV1VWC-l8koyF3VZwTblzxC0_UP_QyUrGsnEjyR2NHUIDQcwlfmpfBctCFrOyVWQlNKv8Hom9VXExl2n1NE0DJwLX7BXlglBExHQhUjmtfLRevPhGON7c0NHUkG3No1wmqlftR6J7Sl9D2_v6LDgnMhdVnf74cYX__LGiP-7--3_u7_kPgYe4NkYuGZciJjzBZEIwY2hjPUjygaJkeoEARYLqTIllYzRYmFmu_ixWj0mH_ygXp9naLvdGtod0QuoqF5-Rb6pGVKy0coaspqtG0eGL5wFcANqCFpY1efpS1KMv9J10xUSerDKWr69bsW2CZZG4sbqW8pKcqLVlSEw8Qu8amhGCjzQbvYeIa8RjOs7IIh7Br26FiYRXp5hBKJhUEqdQnbIlv4srzBqQEGy5SRyrklAMF6beyfRCAkEULxZoizuKkki9qNQko2WBVqcAzUKy0aqaq6qsk3NrBTPEQhhBVNdztR6N9sb218qZUvp_kDTCUSLxAriJKaRo1JOmAk05vpb0Uc5A4d0FLbGFicVCSkZPS7wvLDq4FiKKMC2sdYUo5ghXNgYfIzgSrFyYQ42gUieoirZTGh6YFSYhMmYzGaFhFRrdU8eMA5v4p_OCcqHRgFJfKC88sCnigQQjjspVa2hNHGMAObgyLU25urk8sKus3KwW0XY0nJwb9DNzJlhZl86gVyHwGMfu1twNI-MKLoIm09Ii3fTYUhEO9Qwt2uypD2xOzsnQI0mAc5wYO44_0SjziMC0XHBRKIwtipAotCh-pF0w4Axxz4HhNfUI9BZZSJWRav0bCaq6LhcDgh1aEf1ZntB7EUXt60NME2-mbW6qiYG821aZmxxdXlhbHqjroUDeS1xMawfbRGotBKWHrSlpoYEBogtnXG4e0zesGrajHNMuYGiQ7trk2IRWWppu70oNLx4glrA_vRcX5koVV9Z2dtRohC0OACWxuQ21FIUOL8xOVat0K1bB8SAKDYRbixBBhIKj6gqLtDQu_Y-RVQIXUeJC3LGiaqlpKAskQ8cabfXg3kg1srioAYVVo-w9XhYgWbimsYe6SsXpInUqzZBlkCYu5gwWkok5SGRr45r5vRuKteVZ5Y5LGg==)
```lua
-- Let's draw the earth!
-- We will build up a heightmap by summing sinusoids. More specifically, we will sum
-- 12 functions of the form a*sin(b*x + c*y + d).
-- The 48 parameters have been chosen meticulously so that the sinusoids interfere just right
-- to resemble the earth's surface. Then we massage the parameters so we can efficiently encode
-- them into the PICO-8 program. See the python files in the supplemental/ directory for the
-- code used to generate these parameters and transform them (TODO create the supplemental/ directory).
-- 
-- We start with the string holding the encoded parameters. Each parameter is 
-- encoded as 2 base-64 characters. A pair of values xy corresponds to a fixed point 
-- value 0b0.00yyyyyy_xxxxxx00
-- This encoding scheme only supports non-negative values below 1/4. 
-- This is fine for the most part because for any sinusoidal with negative a, b, or d, 
-- we can turn the values positive using trig identities. However, if b and c have opposite
-- signs, that is invariant under any manipulations we do. But we account for that by
-- sorting all parameter groups with c<0 at the end. This allows us to restor the negative
-- sign with minimal characters later on.
-- To account for the 1/4 restriction, we will simply multiply the values by 4 as needed. `d` is 
-- really the only parameter that requires a range from 0 to 1 (this is due to PICO-8's trig functions
-- using a convention where the period is 1 instead of 2pi). The other parameters can be
-- manipulated to be in a smaller range.
-- 
-- Due to some optimizations, the format is aabbddcc instead of aabbccdd.
-- Notice that this string is only 94 characters long instead of the expected 2*48=96.
-- Luckily there was a parameter group with c=0, so we put that group last, and can omit characters
-- for it. When the string is read into memory, the bytes corresponding to the last parameter will 
-- naturally be 0.
w="+)G%K*C#+0?#;/_#?5S#7U7$'-W#/:/%#+3$+D[&31+$?3C$G-O#;8?$O9O$Ka3$+B##SC+$K2+$#M7#[D;#7[+#7:K$?9"
q=1
::_::
-- We will poke the parameters into memory, 2 bytes per parameter, starting at address 1.
-- ord(w[q])-35 gives you a value between 0 and 63
-- For the most significant byte, we leave this value as is.
-- For the least significant byte we need to pad with 2 0 bits. We can do this by bit shifting
-- <<q%2*2 accomplishes selectively shifting by 0 or 2 bits.
if(w[q])poke(q,ord(w[q])-35<<q%2*2)
x=q%128
y=q\128
height=0
-- Loop through all 12 groups of parameters
for i=1,89,8do
  j=i+4
  -- Here is where we calculate a*sin(b*x + c*y + d) for current particular parameter group.
  -- 
  -- The unary `%` operator reads 2 bytes starting at the supplied memory address. The
  -- bytes are read as a 16-bit integer.
  -- The unary `$` operator reads 4 bytes starting at the supplied memory address. The
  -- bytes are read as a 32-bit fixed point number.
  -- PICO-8 uses little-endian, so $i is approximately equal to %(i+2). So mixing
  -- 2-byte and 4-byte reads allows us to avoid something like %i*sin(%(i+2)*x + %(i+6)*y + %(i+4)),
  -- saving a lot of characters.
  -- 
  -- Our parameters are stored in memory as positive values. Because we sorted our parameter
  -- groups so that the ones with a negative c are last, we can just negate the c parameter
  -- once our i value gets past a certain point. Hence multiplying by `sgn(25-i)`.
  -- 
  -- We want to turn our 16-bit integers into 16-bit floats between 0 and 1. But remember the 
  -- leading 2 bits are 0. So shifting by 14 effectively multiplies by 4.
  -- For the outermost shift, shift by 13 to multiply by 8. This allows us to use a value of
  -- 1 for the threshold for land later on.
  height-=%i*sin(x*$i+sgn(25-i)*y*$j+%j>>14)>>13
end
-- Start with dark blue for water
color=1
-- We could set positive sections of the heightmap as land and negative sections as water,
-- but it looks a little nicer if we use 1 as the cutoff.
-- 3 is green for land, 7 is white for snow. `sgn(y-53)` tells us if we are in Antarctica.
-- So we calculate 5 +/- 2 accordingly.
if(height>1)color=5+2*sgn(y-53)
pset(x,y,color)
-- Increment q, and wrap around back to 1 when we finish drawing the map.
-- This is useful since on the first pass the map is a little corrupted
-- because the parameters haven't been fully written into memory at the start.
q=1+q&8191
goto _
```





## About




Source code available on [GitHub](https://github.com/MiniMechMedia/pico8-games/tree/master/carts/hello-world-tweet)


## Acknowledgements
This technique was inspired by the [plasma effect](https://en.wikipedia.org/wiki/Plasma_effect) used in [demoscene](https://en.wikipedia.org/wiki/Demoscene)

