pico-8 cartridge // http://www.pico-8.com
version 35
__lua__
--galaxy tweet                   v0.1.0
--by caterpillar games 



::_::
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
goto _

__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000070000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000070000000000000000
00000000000000000000000000000000000000000000000000000000a00000000000000007000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000f0000000000070a0000000000000000000000000000000000000000000000000000700000000000
00000000000000000000000000000000000000000000007f00000007007f00000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000070000007000007000077070000000000000000000000000000000000000000000000000
00000000000000000000000000000000000007007000007000000000000000000007000000707000000000000000070000000000000000000000000000000000
00000000000000000000000000000000000007000000000000000007000000000000007000070070070000000000000000007000000000007000000000000000
00000000000000000000000000000000000000700000000000000000000000700007000000007000000000000000000000000000000000000000000000000000
00000000000000000000000000000000770000000700000000000000070700000007000000000000000077000000000000000000000000000000000000000000
00070000000000000000000000000000000700000000000000700000000000000000000000000070000700000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000070000000000700000000000000000000000000000000000000000
00000000000000000000000007700000000000000000000000000000000000070000000000700a00000000000000000700000000000000000000000700000000
0000000000000000000000007000000000000000000000000000000000000000000000000000000000070f000070000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000f000000070000000000000000700000000007000007000000000000000000000000000000000000
00000000000000000000000000000000000000000000007000000000000007000000000000000000000000000707000000000000000000000000000000000000
00000000000000000007000000000000000000700000000000000000770000000000000000000000000000000000000000000000000000000000000000000000
000000000000000007000000070000000000000000000000000000000f000000000000000000000000000a000000000700000000000000000007000000000000
00000000000000000070000000700000700000000000000700000000000000007000000000000000000000700070000007000000000000000000000000000000
00000000000000007000000000000000070000000000000000000000000000000000000707000000000000000000000000a00000000000000000000000000000
000000000000000a0000700007000000000000000000000000000000007000700000000000000000000000000007000000000000000000000000000000000000
00000000000000000000000000000000700000000000000000000000000000000000000000000000000000000f00000000000000000000000000000000000000
00000000000000707000000000000000000000000000000700000007700000000000700000000000000700000000007700000700000000000000000000000000
00000000000000000000000000000000000000000000000000f0700f070000000007000007000000000000000000000000000a00000000000000000000000000
000000000000000000000000000000700000000700a00700007707077f7f77007770007070000000000000000000000000070007000000000000070007000000
00000000000000000000000000000000070000007700070700000700070000700070007000700000000000000000000000000000000000000000000000000000
00000000000000000000f000000000000a00000700000007000000000700000a000000700000700000000000000000077a007070000000000000000000000000
000000000700000000000000000000000000070700f0000000000000000000000007000a70770000000000070700000000000000700000000000000000000000
000000000f0000000000000000000000007707000000000000000000000000000000007000707077000000000007000000000000070000000000000000000000
00000000000000000000070000000000007007000000000000000000000000000000000070007000000000000000000000000000007000000000000000000000
000000000000007000000000000000000a00000000000000000000000f0070000000000000000077077000000000000000007700770000000000000000000000
00000000000000000000700000000007000f07000000000000000700000000000a00000000000000f00000000000000000000000077000000000000000700000
000000700000000000000000000000007000000000000000000000000000000000700070000000000000f0000000000000000007000000000000000000000000
000000000000000000000000070000000000000000000000000000700700000000000007700000000070070000a0000000000070700700000000000000000000
0000007000000000000000000000000707000a000f00000007007000a000f0070000000000000000000700700000070000000000007000000000000000000000
0000000000000000000000070007707a00000000070000000007000007000000000000000000700070000f070000007000000000000000000000000000000000
00000000000000000000000000700007000700000000700000700000000000000000000700000000000700f70000000000000000000a07000000000000000000
00000000000000000000000007070000000000000000000000000000000000000070000000000000000700707000000000000007770007700000000000000000
000000000000000070000070af00070000000000000000700000000007707077700000f000007000000000000707000700000000f00000000000000000000000
00000070000000000000000f00007000000000070000007000000000000000000000700000000070000007007700000000000000000707700000070000000000
000000007000000000000000070700007070700000000a00000000aa0777af00f0000000007000000070000000a0000000000000000000000000000000000000
000000000000000000000000070700000000000007000007707707070000707077f00000000000700000000700700000000000000f000f000000000000000000
000000000000000000000007f0a000000000000000000007a0007000000f000007777a0700000000000000000000770000000000000077000070000000000000
000000000000000000000077a00000000000000000000a70a000000700000f0000770f0a0000000f00000000077a000000000000000000000000000000000000
000000000000000000000007a700000000000000070007007070007070007000000077000000000000000007007770a000000000f07000700000000700000000
00000000000000000000000000000000000000000007700000000000000700000070707770000000000700000070770000000000000070000000000000000000
00000000000000000000a000000000000000f000007707000000000000707000a70f00000a00000000000000000000700000000000007f000070000000000000
000000000007000000a00007000000000000070007000077000000000000700000000000a707000770f00000000770000000007000000000a000000000000000
00000000000000000070007000000000000700007f000007000000007000f0000000000000070f00000000000000000000000000000000000000000000000000
000000070007000000700000700000000000000a770700000007000f0000000000077007777f000f000000000000070000000000000000000000000000000000
00070000000000000007000f00000000000007700000000000007f0000f00a70000000700007ff007000700000000f0f0f000000000000000070000000000000
00000f00000000000700000000000000000077700000000000007700700000707000000000707a0000070070f0000770070000000000000000a0000000000000
00000000000000000000000000000000000007f000000000000000700000aa070f0077707007a00700000000000007f00000000000000070f700000000000000
000000000000000000000000000000700007770700000000000f00f00a00000700700770f000770000000700000000000007000000000000aa00000000000000
0000000000000000000000000000000000707a00000a0077000000700700f70f70000000700707700000000000000070000f0000000000000a00007000000000
000000000000000070070000000000000000007000000000000000000f77770f0f70070f0707f70000000000000007000000000000000770f007000000000000
00000000000000007007000000000000007a00000700000000000a777070777777700700000a00000f00007f00700fa0007000000000a0000000000000000000
00000000000007000070700000000070007f770007000000000007f0f007a77077a7000aa7077070a00000000000070000000000000000000000000000000000
000000000000000a000000000000000000070700007000f000000a77a0700f70f0a700770000000700000000a000007007000000000000007000000000000000
00000000000000007000700000000000007f0f00000700007700a77fa007707777070f0aa7000077000000000000007000000000000000700700000000000000
0000000000000700000700000700007000000000000070007a077700007700777f7700700070a700000000000000077000000000000000007000000000000000
0000000000000000000000007000000000770f00000000000000a0070f70f777a7777f7a0770f70007000000000007f000000000000700000000000000000000
00000000000070077000000707000000007000700007000000f0a00f70f7777a7770a0707700000707fa00700000000000000000000077f00000000000000000
0000000000000000070000000000700000700f000070000007a0770770077f77770a7a707f77700007000700f000af0000007000000000000000700000000000
00000000000000007000000000000070007700000000700070700707000707f07777a0007007a00000000000000f707007070000000070000000000000000000
0000000000000000000000000000000077070000f70700070777007000000777ff770070070f000f070000000000770000000070700000007000000000000000
0000000000000000000700000070000007700f0000000000000770a0000000a7f0707f707770000070000000000070070f000000000000077000000000000000
0000000000000000000000000000000007070070000000077a70a000af00700070a7707770700000000000070007700000000000000700000000000000000000
00000000000a0000000000000000000700700000000000000077af007f7007007707707077707700000000007007000000000000000707000000000000000000
000070000000000770700000000000000a000000000700000007000a070070707700000070000f00000000000000700700000000000700070070000000000000
00000000000007000070000000000000077a000a0f000000070a0007707007070a000007f00000000000f0000070000000000000000000000000000000000000
00000000000000000a7000000070700007707000000000000007f000070077000f0007000700000000f000000070000000000000077000000000000000000000
000000000000000000000000000f00000f700000f00000000770007070000000000a070000000000000700000700000000000000000000700000000000000000
000000000000000000000000000000000000000000007000007007af0700a7000070000700000000000000007700000000000000000007000000000000000000
000000000000000000000000000000000007000000000000000f7707070000070000000000000000000000077000000000000000f70070700000007000000070
0000000000000000700000700000000000a700000f00007000000000000000000070000000000000000000700000070000000000000000000000000000000000
0000000000000000a000000000000000007a0700000000077000a7700070000f00770000000000000000707000000000000000007007f0007000000000000000
70000000000f00007000000000000000000000000000000070770000000000000000700077000000000077000000700000000000700700000000000000000000
00000000000000000070700000000000000700000070000000007007700000000070000000007000070fa0000000000070000000000700000000000000000000
000000000000000007000000000000000007000000000000700000007700700707000700000000a0faf700000000000000000070070000070000000000a00000
000000000000000070070700000000000000f0000000000000007000070077000700070000070070770f000700000000007077000f0000000000000000700700
00000000700000000000070700000000000007a0700000000000700000f770700000700000000700000007070000000000000000000000000000000000000000
0000700000000070000000000000000000007770000000000000070000700707f000007000077000000700000700000000000000070000000f00000000007000
0000000000000000700007000000000000700ff000000000000000077000000077a777f777f00007000070000000000000070000700000000000000000000000
000000000000000007070000000000000000f0f0070a0000000000000000000070070000000000000000007a7000000000000770707000000000000000000000
000000000000000000a7007000000000000000700007007000000000000000070000000700000a00070000000000070000000000000000000000000000000000
0000000000000000000000070000a00000000000700000000000000000000f000000007000000000700000000000007000f00007000700000700007000000000
00000000000000000000070007000000000000007070007070007700007000070000000000000000000070000000000007000700070000000000000007000000
0000000000000000000000a7000000000000000000770000000a0000000000000000000000a07000000000000000000000000000000000000000000000000000
000000000000000000000007070000070000f0000f0f700000000000000000000000000000000000000000000000070000000000000000000000000000000000
00000000000000000000700000007000000000070007000000000000000700000000000000000000000000000000007f00000000000070000000000000000000
00000000000000000000000000070000000000007000007070000000070000000007700000000000007000000070007f70000000000000000000000000000000
000000000000000000000700000000000000000000007000000000a00000000007000000000000000000000a0007a700000f0000070000000000000000000000
000000000000000000000000000fa000000000000000007707700000000000000000000000000000000000000000000700070000000000000700000000000000
0000000070000000000007000000070000000000000000070700000000000f000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000a00f007000000000070a000700000000700000700000000007000a000f000700000000000000000000000000000000000
00000000000000000000000070000000000000000000000000f70a700000000000000000000000000070070f0070000000007070000000000007000000000000
00000000000000000000000000000000000000000007000000000770a0700000000000007000000077000700000a000000000000000000000000000000000000
000000000000000000000000f00000700000000700000000000077770000a7700000000000707070070000700000000000000000000000000000000000000000
0000000000000000000070000000000000000000000007070000700a070770777000077007700f0007f000000000000000000000000000000000000000000000
000000000000000000000000007000070707000000000000000000000070f7770000007707000700000700000000000000000000000000000000000000000000
0000000000000000000000000007000770070000000000000000a000000007f707700000f77777a0000000000707000000000000000000000000000000000000
00000000000000000000000700000000000000000000000000000f00000000000000000000000700000000000000000700000000000000000000000000000000
00000000000000000000000000000070000000000000000000000000000000000007000000000f00000000000000000000000000000000070000000000000000
000000000000000000000000000000700000000000000000000000000000000007000000f0000000000000000000000000000000000000000000000000000000
000000000000000000000000000000077000000707000000000000000000700000000000000000000000000000000000070000000000000a0000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000000000
000000000000000000000000000000000a0f000007007000000000000000000a0000000000000000000070000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000f00000070000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000a0700000000f000000000000000700a0000000000000000070000000000000000000000000
0000000000000000000000000000000000000707000070000a000070000000000000000000000000000000000000000000770000000000000000000000000000
00000000000000000000000000000000000000000000000700000000000000070000000000000000000000000007000007000000000000000000000000000000
000000000000000000000000000000000000000000000000700000700007000000000000000000000000000000070000000f0000000000000000000000000000
0000000000000000000000000000000000000000070000000007000000000000000000000000000000000000000000000000a000070000000000000000000000
00000000000000000000000000000000000000000070000000000000000000000077000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000070000000000007000000000000007000000a000000000700f0000000000000000000000000000000
70000000000000000000000000000000000000000000000700000000000777000000000000000000000000077000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000007700770007000007700000000000000000f0000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000007000000000000000000000000000700000000000000000000000000000000000000000
00000000000070000000000000000000000000000000000000000000000000000077000000070000700000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000070000000000a0070000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000700000700000000000000000000000000000000000000000007000000
00000000000000000000000000000000000000000000000000000000700000000000700000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070000000000000000000000000
