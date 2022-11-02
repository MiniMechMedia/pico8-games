
-- Here
old_draw = _draw
-- old_init = _init

-- fu
	local fullss = 'bbbbbb00010bbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbb101010101bbbbbb0aaaaaafaffffffffffffff9999999999494444442222222e2eededdddddddcdccccccccc1c1c1c11111111110bbbbbbbbbbbbbbbbbbbbbb00001010101bbbbb0aaaaaaafaffffffffffffff9f99999999494444442222222e2eeddddddddddcdccccccc1c1c1c111111111110bbbbbbbbbbbbbbbbbbbbb0010101111111bbbb0aaaaaaaafafaffffffffffff9f999999994944442422222e2eededdddddddcdccccccc1c1c111111111111110bbbbbbbbbbbbbbbbbbbb000010101011101bbb0aaaaaaaaafafaffffffff66666f9666669946664422266666ed6666666dd666666666cc1c1111111111111110bbbbbbbbbbbbbbbbbbbb000101011116111bbb0aaaaaaaaaafafaffffff6777776f677769667776642267776ee67777776c677777776c1111111111111111100bbbbbbbbbbbbbbbbbbb0000010101167d110bb0aaaaaaaaaaafafafafff677777766777667777777626677776e6777777766777777761c111111111111111010bbbbbbbbbbbbbbbbbbb000010101111d1111bb0aaaaaaaaaaaaaafafaff677777776777667777777666777776e677777777677777776c1111111111111010100bbbbbbbbbbbbbbbbbbb00000101010111010bb0aaaaaaaaaaaaaaafafaf677767776777677776777766777777667777777767776666611111111111110101000bbbbbbbbbbbbbbbbbbb00000010111111111bbb05a5aaaaaaaaaaaafafa67776677677767776666666677677766777667776777777761111111111110101000bbbbbbbbbbbbbbbbbbbb00000101010101010bbb0a5a5a5aaaaaaaaaafaf67777777677767777677776777677766777767776777666661111111110101000000bbbbbbbbbbbbbbbbbbbbb000001010101010bbbb0555a5a5aaaaaaaaaafa67777776677766777777776777767776777777776777777761111111101010000000bbbbbbbbbbbbbbbbbbbbb000000001010101bbbb0555555a5a5aaaaaaaaf67777766677766777777767777767776777777766777777761111101010100000000bbbbbbbbbbbbbbbbbbbbbb0000001010101bbbbb0555555555a5a5aaaaaa6777666f6777696777776677777667767777776c6777777761111010101000000000bbbbbbbbbbbbbbbbbbbbbbb00000000000bbbbbb05555555555a5a5aaaaa66666fff666669966666266666666666666666cc6666666661010101010000000000bbbbbbbbbbbbbbbbbbbbbbbb000000001bbbbbbb05555555555555a5a5aaaaaafafaffff9999494444222e2eeddddddcdccccc1c111110101010000000000000bbbbbbbbbbbbbbbbbbbbbbbbb0000000bbbbbbbb055555555555555a5a5aaaaaafaffff9f9999444422222eededdddcdccccc111111101010100000000000000bbbbbbbbbbbbbbbbbbbbbbb0005d667000bbbbbb055555555555555555a5aaaaaafaffff9999494444222eeeeddddddccccc1111111010100000000000000000bbbbbbbbbbbbbbbbbbbbbb00005d6670101bbbbb0555555555555555555aaaaaaaafaff9f9999444422222eeddddddccccccc111110101000000000000000000bbbbbbbbbbbbbbbbbbbbb000015d66710100bbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbb0000105d667110101bbbbbb05555555555555555aaaaaaaffffff999944442222eeeedddddcccccc1111111000000000000000000bbbbbbbbbbbbbbbbbbbbbbb00000105d51101000bbbbbb0555555557777777777777777777777777777777777777777777777777777777777777777000000000bbbbbbbbbbbbbbbbbbbbbbb00001011111110101bbbbbb0555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7000000000bbbbbbbbbbbbbbbbbbbbbbbb000010101010100bbbbbbb0555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7000000000bbbbbbbbbbbbbbbbbbbbbbbbb0010101010101bbbbbbbb0555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7000000000bbbbbbbbbbbbbbbbbbbbbbbbbb00000010000bbbbbbbbb0555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbb0101010bbbbbbbbbbb0555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000bbbbbbbbbbbbb0555555557bbbbbbbbbbbbbbbbbbbb44444bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7000000000bbbbbb00010bbbbbbbbbbbbbbbb10101101bbbbbbbbbbb0555555557bbbbbbbbbbbbbbbbbb44aaaaafbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7000000000bbbb101010101bbbbbbbbbbbbb0000100101bbbbbbbbbb0555555557bbbbbbbbbbbbbbbbb449aaaaaaf4bbbbbbbb44444bbbbbbbbbbbbbbbbbbbbb7000000000bbb00001010101bbbbbbbbbbb001010111111bbbbbbbbb0555555557bbbbbbbbbbbbbbbb449aaaaaaaaf5bbbbb44aaaaafbbbbbbbbbbbbbbbbbbbb7000000000bb0010101111111bbbbbbbbb00001010011101bbbbbbbb0555555557bbbbbbbbbbbbbbb444aaaaaaaaaafbbbb4a9aaaaaaf4bbbbbbbbbbbbbbbbbb7000000000b000010101011101bbbbbbbb00010101116111bbbbbbbb0555555557bbbbbbbbbbbbbbb444aaaaaaaaaafbbb4a9aaaaaaaaf5bbbbbbbbbbbbbbbbb7000000000b000101011116111bbbbbbb000001010167d110bbbbbbbb055555557bbbbbbbbbbbbbbb4449aaaaaaafafbb444aaaaaaaaaafbbbbbbbbbbbbbbbbb700000000b0000010101167d110bbbbbb0000010100111010bbbbbbbb055555557bbbbbbbbbbbbbbbb4449aaaaffaafbb444aaaaaaaaaafbbbbbbbbbbbbbbbbb700000000b000010101111d1111bbbbbb0000001011111111bbbbbbbb055555557bbbbbbbbbbbbbbbb49999aaaaaaa5bb4449aaaaaaafafbbbbbbbbbbbbbbbbb700000000b00000101010111010bbbbbb0000010100101010bbbbbbbb055555557bbbbbbbbbbbbbbbbb49aaaaaaa45bbbb4449aaaaffaa5bbbbbbbbbbbbbbbbb700000000b00000010111111111bbbbbbb00000101101010bbbbbbbbb055555557bbbbbbbbbbbbbbbbbb44aaaaa45bbbbbb4499aaaaa4bbbbbbbbbbbbbbbbbbb700000000b00000101010101010bbbbbbb00000000010101bbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbb4444bbbbbbbbbbb4444444bbbbbbbbbbbbbbbbbbbb700000000bb000001010101010bbbbbbbbb000000110101bbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bb000000001010101bbbbbbbbbb0000000000bbbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bbb0000001010101bbbbbbbbbbbb00000001bbbbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bbbb000000000007bbbbbbbbbbbbbb0000bbbbbbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bbbbb00000000167000bbbbbbbbbbb5d67bbbbbbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bbbbbbb000005d6670000bbbbbbbbb5d67bbbbbbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bbbbbbbbb0005d66710101bbbbbbb05d6700bbbbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbb24eeee5bbbbbbbbb555d551bbbbbbbbbbbbbbbbbbbb700000000bbbbbbbb000015dd5010100bbbb0005d667000bbbbbbbbbb055555557bbbbbbbbbbbbbbbbbb4eeeeeeedbbbbbbb53cccccd5bbbbbbbbbbbbbbbbbbb700000000bbbbbbb00001015d11110101bb00005dd670101bbbbbbbbb055555557bbbbbbbbbbbbbbbbb4eeeeeeeeedbbbbb5dcccccccd5bbbbbbbbbbbbbbbbbb700000000bbbbbbb00000101111101000b000015dd6710100bbbbbbbb055555557bbbbbbbbbbbbbbbb24eeeeeeeeefdbbb5dcccccccccdbbbbbbbbbbbbbbbbbb700000000bbbbbbb0000101111111010100001015d51110101bbbbbbb055555557bbbbbbbbbbbbbbbb44eeeeeeeeef6bb151cccccccccc5bbbbbbbbbbbbbbbbb700000000bbbbbbbb000010101010100b00000101111101000bbbbbbb055555557bbbbbbbbbbbbbbbb444eeeeeeefefbb1d11cccccccccc5bbbbbbbbbbbbbbbb700000000bbbbbbbbb0010101010101bb00001011111110101bbbbbbb055555557bbbbbbbbbbbbbbbb4444eeeee7feebb51d1dccccccccc5bbbbbbbbbbbbbbbb700000000bbbbbbbbbb00000010000bbbb000010101010100bbbbbbbb055555557bbbbbbbbbbbbbbbb24e44eeefeeedbbd1ddd3cccccccc5bbbbbbbbbbbbbbbb700000000bbbbbbbbbbbb0101010bbbbbbb0010101010101bbbbbbbbb055555557bbbbbbbbbbbbbbbbb44eeeeeeee4bbbf5ddccccccc665bbbbbbbbbbbbbbbbb700000000bbbbbbbbbbbbbbbbbbbbbbbbbbb00000010000bbbbbbbbbb055555557bbbbbbbbbbbbbbbbbb24eeeeee4bbbbbd15dccccc67dbbbbbbbbbbbbbbbbbb700000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbb0101010bbbbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbb2244442bbbbbbbb55dcccccdbbbbbbbbbbbbbbbbbbb700000000bbbbbbbbbbbbb00010bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbdddddddbbbbbbbbbbbbbbbbbbbb700000000bbbbbbbbbbb101010101bbbbbbbbbbbbbbbbbbbbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bbbbbbbbbb00001010101bbbbbbbbbbbbbbbbbbbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bbbbbbbbb0010101111111bbbbbbbb000010bbbbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bbbbbbbb000010101011101bbbbb1010110101bbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bbbbbbbb000101011116111bbbb000010010101bbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bbbbbbb0000010101167d110bb00101011111111bbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bbbbbbb000010101111d1111b0000101001011101bbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bbbbbbb00000101010111010b0001010111116111bbbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbbbbbb0000001011111111100000101001167d110bbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbbbbbb000001010101010100000101011111d1111bbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbbbbbbb000001010101010b000001010010111010bbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbbbbbbb000000001010101b000001010010111010bbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbbbbbbbb0000001010101bb000000101111111111bbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbbbbbbbbb00000000000bbb000001010010101010bbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbbbbbbb005000000001bbbbb0000010110101010bbbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbbbbb00005d600000bbbbbbb0000000001010101bbbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbbbb000055d667101bbbbbbbb00000011010101bbbbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbbb000015d66670100bbbbbbbb000000000000bbbbbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbb0000105d667110101bbbbbbb00000000001bbbbbbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbb0000010d577101000bbbbbb0000000000101bbbbbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbb00001011511110101bbbbb000015d66710100bbbbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbbb000010101010100bbbbb0000105d667110101bbbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbbbb0010101010101bbbbbb00000105d51101000bbbbbbbb055555577777777777777777777777777777777777777777777777777777777777777770000000bbbbbbb00000010000bbbbbbb00001011111110101bbbbbbbb0555555555555555555aaaaaaaffffff999944442222eeeedddddcccccc1111111000000000000bbbbbbbbb0101010bbbbbbbbbb000010101010100bbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbb0010101010101bbbbbbb055555555555555555555aaaaaaaaffffffff9994442222eedddddddcdcccccc11111100000000000000bbbbbbbbbbbbbbbbbbbbbbbbb00000010000bbbbbbb05555555555555555555555aaaaaafaffffff9999944422eeeedddddddcdcccc1c11110100000000000000bbbbbbbbbbbbbbbbbbbbbbbbbb0101010bbbbbbbbb0555555555555555555555aaaaaaaaffffff9f9994942222eedddddddcdcccccc111555d55510000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0555555555555555555555a5aaaaaafaffff9f9994942422eeeedddddddcdcccc1c115dccccc510000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb055555555555555555555555aaaaaafaffffff999994442222eededddddcdcccccc111cccccccc510000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb05555555555555555555555a5aaaaaafaffff9f9994942222eeeedddddddcdcccc1113ccccccccc55000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb05555555555555555555555a5aaaaaafaffff9f999494222222eeeedddd24eeee50c113cccccccccc55000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb05555555555555555555555a5aaaaaaaaffff9f999494242222eeeedddd4eeeeeeed0111ccccccccccd50000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0555555555555555555555a5a5aaaaaaffffff9f949424222222eeeedd4eeeeeeeeed0d11cccccccccc50000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0555555555555555555555a5a55aaaaafaffff9f999494222222eeeede24eeeeeeeeefd1dd3ccccccccd500000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0555555555555555555555a5a55aaaaaaaffff9f99949422222222eeeed44eeeeeeeeef61ddcccccccccd5000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb055555555555555555555a5a55aaaaaaaffffff9f949422222222eeeeee444eeeeeeefef515cccccc67d50000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbb0555555555555555555a5a5a555aaaaaafaffff9f94942422222222eeeed4444eeeee7fee55513cccc6d5000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbb055555555555555555a5a5a555aaaaaafaffff9f99942422222222e2eeee24e44eeefeeed11153cccdd50000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbb05555555555555555555a55555aaaaaafaffff9f9994942222222222eeeeee44eeeeeeee41153ccccccd500000000000000000bbbbbbbbbbbbbbbbbbbbbbbbb05555555555555555555a55555aaaaaaffffff9f999994242222222222eeeedd24eeeeee4115dccccccccd500000000000000000bbbbbbbbbbbbbbbbbbbbbbbb0555555555555555555a5a555aaaaaaafffff9f999994242222222222eeeeeedd2244442c15dccccccccccd50000000000000000bbbbbbbbbbbbbbbbbbbbbbb0555555555555555555a5a555aaaaaaffafff9f99999424222222222222eeeeee24eeed5cc151ccccccccccc510100000000000000bbbbbbbbbbbbbbbbbbbbb05555555555555555a5a5a555aaaaaaffffff9f99999424222222222222e2eee44eeeeeee5c551dccccccccccd510100000000000000bbbbbbbbbbbbbbbbbbbb0555555555555555a5a5a55aaaaaaaffffff9f9999999424222222222222eee44eeeeeeeee51d11ccccccccccc501010000000000000bbbbbbbbbbbbbbbbbbb05555555555555a5a5a5a5aaaaaaaaffffffff9999999444222222222222e2ee44eeeeeeeeee51d1dcccccccccc5101010100000000000bbbbbbbbbbbbbbbbbb0555555555555a5a5a5aaaaaaaafffffffff9999999944424222222222222ee44eeeeeeeeeefd1ddd3ccccccccc5110101010100000000bbbbbbbbbbbbbbbbbb055555555555a5a5aaaaaaaaaafafffffff999999994942422222222222222e44eeeeeeeeeeff5ddcccccccc6651111110101010100000bbbbbbbbbbbbbbbbbb055555555a5a5aaaaaaaaaaaffffffffff999999999944424222222222222e2444eeeeeeeefffd15dcccccc67d51111111110101010000bbbbbbbbbbbbbbbbbb05a5a5a5a5a5aaaaaaaaaffffffffffff999999999944424222222222222222444eeeeeeef7e7d555dccccccd511111111111110101000bbbbbbbbbbbbbbbbbb0a5a5a5a5aaaaaaaaffffffffffffff999999999994442422222222222222242444eeeee77e77dcccddddddd5111111111111111111100bbbbbbbbbbbbbbbbb0a5aaaaaaaaaaafaffffffffffffff999999999999444442422222222222222f24ee4eeeffef76cccccccccc1c1111111111111111111110bbbbbbbbbbbbbbbb0aaaaaaaafafafffffffff9ffff9999999999999949444242222222222222222e24eeeeeef776cdcccccccccc1c111111111111111111110bbbbbbbbbbbbbbbb0aaaaafafaaafffffffff9f999999999999999494944424222222222222222222ee44eeef776cdcccccccccc1c1c11111111111111111110bbbbbbbbbbbbbbbb0fafafafafafffffff9f9f999999999999999494944424242222222222222222e2eeedeee6dddcdcccccccccc1c1c1111111111111111110bbbbbbbbbbbbbbbb0afafafffffffff9f9f9f99999999999999949444444424222222222222222222e2eeeeeddddddcdcccccccccccc1c1c1111111111111110bbbbbbbbbbbbbbbb0fffffffffff9f9f9f999999999999999494944444442422222222222222222222e2eeeeddd5dddcdcccccccccccc1c1c111111111111110bbbbbbbbbbbbbbb0fffffffffff9f9f9999999999999994949494444444242222222222222222222222e2eeeddddddddcccccccccccccc1c1c111111111111110bbbbbbbbbbbbbb0fffff9ffff9f999999999999999494949494444444242422222222222222222222e2eeeeeddddddcdcccccccccccccc1c1c11111111111110bbbbbbbbbbbbbb0fffffff9f9f99999999999994949494444444444444242222222222222222222222e2eeeeeddddddcdcccccccccccccccc1c1c11111111110bbbbbbbbbbbbbb09f9f9f9f999999999999999494949444444444444424222222222222222222222222e2eeeedddddddcccccccccccccccccc1c1c1111111110bbbbbbbbbbbbbb099f9f9999999999999994949494944444444444442422222222222222222222222222e2eeededdddcdcccccccccccccccccccc1c111111110bbbbbbbbbbbbb099999999999999999999494949444444444444444242222222222222222222222222222e2eeededdddcdcccccccccccccccccccc1c111111110bbbbbbbbbbbb0999999999999999994949494944444444444444424242222222222222222222222222222eeeeeddddddcdcccccccccccccccccccc1c11111110bbbbbbbbbbbb05999999999994449494949494444444444444442424222222222222222222222222222222eeeeeddddddcccccccccccccccccccccc111111110bbbbbbbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbb'

local mymap = {
		["0"] = 0,
		["1"] = 1,
		["2"] = 2,
		["3"] = 3,
		["4"] = 4,
		["5"] = 5,
		["6"] = 6,
		["7"] = 7,
		["8"] = 8,
		["9"] = 9,
		["a"] = 10,
		["b"] = 11,
		["c"] = 12,
		["d"] = 13,
		["e"] = 14,
		["f"] = 15,
		[' '] = nil
	}
	-- Store the original away for safety
	memcpy(0x0000, 0x4300, 8192)

	-- Overwrite the sprite sheet with picade
	local x = 0
	local y = 0
	for i = 1, #fullss do
		sset(x, y, mymap[fullss[i]])
		-- print(mymap[fullss[i]])
		x += 1
		if x > 127 then
			x = 0
			y += 1
		end
	end
	
	-- Save picade ss to other half of general use
	memcpy(0x8000, 0x0000, 8192)


function draw_header()

	-- local header_str = '0000000000000000000000006666666666666666666666666666666666666666666666666666666666666666666666666666666d0000000000000000000000000000000000000000000000006cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc10000000000000000000000000000000000000000000000006cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc10000000000000000000000000000000000000000000000006ccccccddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddcccccc10000000000000000000000000000000000000000000000006cccccd111111111111111111111111111111111111111111111111111111111111111111dccccc10000000000000000000000000000000000000000000000006ccccd1111111111111cccccc111cccccc111cccc1111ccc111ccccc111cccccc111111111dcccc10000000000000000000000000000000000000000000000006cccd11111111111111cc111cc1111cc1111cc11cc11cc1cc11cc11cc11cc11111111111111dccc10000000000000000000000000000000000000000000000006ccd111111111111111cc111cc1111cc111cc111111cc111cc1cc111cc1cc111111111111111dcc10000000000000000000000000000000000000000000000006ccd111111111111111cc111cc1111cc111cc111111cc111cc1cc111cc1ccccc111111111111dcc10000000000000000000000000000000000000000000000006cccd11111111111111cccccc11111cc111cc111111ccccccc1cc111cc1cc11111111111111dccc10000000000000000000000000000000000000000000000006ccccd1111111111111cc111111111cc1111cc11cc1cc111cc1cc11cc11cc1111111111111dcccc10000000000000000000000000000000000000000000000006cccccd111111111111cc1111111cccccc111cccc11cc111cc1ccccc111cccccc11111111dccccc10000000000000000000000000000000000000000000000006ccccccd1111111111111111111111111111111111111111111111111111111111111111dcccccc10000000000000000000000000000000000000000000000006cccccccddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddccccccc10000000000000000000000000000000000000000000000006cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc100000000000000000000000000000000000000000000000011111111cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1111111500000000000000000000000000000000000000000000000045454545454545454545454545454545454545454545454545454545454545454545454545454542000000000000000000000000'
	-- local bottom = '0000000000000000000000006cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc10000000000000000000000000000000000000000000000006cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1000000000000000000000000000000000000000000000000cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc00000000000000000000000000000000000000000000000055aaaa55cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc0000000000000000000000000000000000000000000000006a999946cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000a9999944cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc00000000000000000000000000000000000000000000000099999444cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc00000000000000000000000000000000000000000000000094994444cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000c444444ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000cc4444cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000cc6555cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc00000000000000000000000000000000000000000000000011766511cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc00000000000000000000000000000000000000000000000011566211cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc00000000000000000000000000000000000000000000000011155111cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc00000000000000000000000000000000000000000000000011111111cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc00000000000000000000000000000000000000000000000011111111cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000ddddddddcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc00000000000000000000000000000000000000000000000011111111cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc00000000000000000000000000000000000000000000000011111111cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000000000000000000000000000000000000000000000000111111111111111111111111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000000000000000000001111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000'
	-- local actual = '00000000bbbbbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbb0000000000000000bbbbbbbbbbb0aaaaaafaffffffffffffff9999999999494444442222222e2eededdddddddcdccccccccc1c1c1c11111111110bbbbbbbbbbb0000000000000000bbbbbbbbbbb0aaaaaaafaffffffffffffff9f99999999494444442222222e2eeddddddddddcdccccccc1c1c1c111111111110bbbbbbbbbbb0000000000000000bbbbbbbbbbb0aaaaaaaafafaffffffffffff9f999999994944442422222e2eededdddddddcdccccccc1c1c111111111111110bbbbbbbbbbb0000000000000000bbbbbbbbbbb0aaaaaaaaafafaffffffff66666f9666669946664422266666ed6666666dd666666666cc1c1111111111111110bbbbbbbbbbb0000000000000000bbbbbbbbbbb0aaaaaaaaaafafaffffff6777776f677769667776642267776ee67777776c677777776c1111111111111111100bbbbbbbbbbb0000000000000000bbbbbbbbbbb0aaaaaaaaaaafafafafff677777766777667777777626677776e6777777766777777761c111111111111111010bbbbbbbbbbb0000000000000000bbbbbbbbbbb0aaaaaaaaaaaaaafafaff677777776777667777777666777776e677777777677777776c1111111111111010100bbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbb0aaaaaaaaaaaaaaafafaf677767776777677776777766777777667777777767776666611111111111110101000bbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbb05a5aaaaaaaaaaaafafa67776677677767776666666677677766777667776777777761111111111110101000bbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbb0a5a5a5aaaaaaaaaafaf67777777677767777677776777677766777767776777666661111111110101000000bbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbb0555a5a5aaaaaaaaaafa67777776677766777777776777767776777777776777777761111111101010000000bbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbb0555555a5a5aaaaaaaaf67777766677766777777767777767776777777766777777761111101010100000000bbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbb0555555555a5a5aaaaaa6777666f6777696777776677777667767777776c6777777761111010101000000000bbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbb05555555555a5a5aaaaa66666fff666669966666266666666666666666cc6666666661010101010000000000bbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbb05555555555555a5a5aaaaaafafaffff9999494444222e2eeddddddcdccccc1c111110101010000000000000bbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbb055555555555555a5a5aaaaaafaffff9f9999444422222eededdddcdccccc111111101010100000000000000bbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbb055555555555555555a5aaaaaafaffff9999494444222eeeeddddddccccc1111111010100000000000000000bbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbb0555555555555555555aaaaaaaafaff9f9999444422222eeddddddccccccc111110101000000000000000007bbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbb05555555555555555aaaaaaaffffff999944442222eeeedddddcccccc1111111000000000000000000bbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbb055555555                                                                 00000000bbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbb055555555                                                                 00000000bbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbb055555555                                                                 00000000bbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbb055555555                                                                 00000000bbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbb055555555                                                                 00000000bbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbb055555555                                                                 00000000bbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbb055555555                                                                 00000000bbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbb055555555                                                                 00000000bbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbb055555555                                                                 00000000bbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbb055555555                                                                 00000000bbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbb055555555                                                                 00000000bbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbb055555555                                                                 00000000bbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbb055555555                                                                 00000000bbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbb055555555                                                                 00000000bbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbb055555555                                                                 00000000bbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbb055555555                                                                 00000000bbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbb055555555                                                                 00000000bbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbb05555555                                                                 0000000bbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbb05555555                                                                 0000000bbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbb05555555                                                                 0000000bbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbb05555555                                                                 0000000bbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbb05555555                                                                 0000000bbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbb05555555                                                                 0000000bbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbb05555555                                                                 0000000bbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbb05555555                                                                 0000000bbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbb05555555                                                                 0000000bbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbb05555555                                                                 0000000bbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbb05555555                                                                 0000000bbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbb05555555                                                                 0000000bbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbb05555555                                                                 0000000bbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbb05555555                                                                 0000000bbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbb05555555                                                                 0000000bbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbb05555555                                                                 0000000bbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbb05555555                                                                 0000000bbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbb05555555                                                                 0000000bbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbb05555555                                                                 0000000bbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbb05555555                                                                 0000000bbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbb05555555                                                                 0000000bbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbb05555555                                                                 0000000bbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbb05555555                                                                 0000000bbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbb05555555                                                                 0000000bbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbb05555555                                                                 0000000bbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbb05555555                                                                 0000000bbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbb05555555                                                                 0000000bbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbb05555555                                                                 0000000bbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbb05555555                                                                 0000000bbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbb05555555                                                                 0000000bbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbb05555555                                                                 0000000bbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbbb0555555                                                                 000000bbbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbbb0555555                                                                 000000bbbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbbb0555555                                                                 000000bbbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbbb0555555                                                                 000000bbbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbbb0555555                                                                 000000bbbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbbb0555555                                                                 000000bbbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbbb0555555                                                                 000000bbbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbbb0555555                                                                 000000bbbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbbb0555555                                                                 000000bbbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbbb0555555                                                                 000000bbbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbbb0555555                                                                 000000bbbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbbb0555555                                                                 000000bbbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbbb0555555                                                                 000000bbbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbbb0555555                                                                 000000bbbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbbb0555555                                                                 000000bbbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbbb0555555                                                                 000000bbbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbbb0555555                                                                 000000bbbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbb055555555555555555555aaaaaaaaffffffff9994d42222eedddddddcdcccccc11111100000000000000bbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbb05555555555555555555555aaaaaafaffffff9999944422eeeedddddddcdcccc1c11110100000000000000bbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbb0555555555000000005555aaaaaaaaffffff9f9994942222eedddddddcdcccccc1111555d5551000000000bbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbb0555555550011111111005a5aaaaaafaffff9f9994942422eeeedddddddcdcccc1c1115dccccc51000000000bbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbb055555555501111111111105aaaaaafaffffff999994442222eededddddcdcccccc1111cccccccc51000000000bbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbb0555555550001111111111055aaaaaafaffff9f9994942222eeeedddddddcdcccc1c113ccccccccc5500000000bbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbb0555555555000111111551100aaaaaafaffff9f999494222222eeeeddddd24eeee5c1113cccccccccc5000000000bbbbbbbbbb00000000bbbbbbbbbbbbbbbbb055555555501001111155dd110aaaaaaaffff9f999494242222eeeeddddd4eeeeeeedc111ccccccccccd5000000000bbbbbbbbb00000000bbbbbbbbbbbbbbbbb05555555550110111115d66510aaaaaaffffff9f949424222222eeeeddd4eeeeeeeeed0d11cccccccccc5000000000bbbbbbbbb00000000bbbbbbbbbbbbbbbb05555555555011111105d677100aaaaafaffff9f999494222244444eded24eeeeeeeeefd1dd3ccccccccd50000000000bbbbbbbb00000000bbbbbbbbbbbbbbb055555555555011111000d677500aaaaaaffff9f99949422244aaaaafedd44eeeeeeeeef61ddcccccccccd500000000000bbbbbbb00000000bbbbbbbbbbbbbbb055555555555001110010555d500aaaaaffffff9f9494222449aaaaaaf41444eeeeeeefef515cccccc67d5000000000000bbbbbbb00000000bbbbbbbbbbbbbb05555555555555000000000150000aaaafaffff9f9494242449aaaaaaaaf54444eeeee7fee55513cccc6d500000000000000bbbbbb00000000bbbbbbbbbbbbbb0555555555555500000000000000aaaafaffff9f9994242444aaaaaaaaaaf24e44eeefeeed11153cccdd5000000000000000bbbbbb00000000bbbbbbbbbbbbb0555555555555555000000000000aaaafaffff9f99949422444aaaaaaaaaaf544eeeeeeee4c153ccccccd50000000000000000bbbbb00000000bbbbbbbbbbbb0555555555555555550000000000aaaaffffff9f9999942424449aaaaaaafafdd24eeeeee4c15dccccccccd50000000000000000bbbb00000000bbbbbbbbbbbb0555555555555555555a0010550aaaaafffff9f999994242224449aaaaffaafdd52244442cc5dccccccccccd0000000000000000bbbb00000000bbbbbbbbbbb0555555555555555555a5a11d67511affafff9f99999424222249999aaaaaaa5ed24eeed5cc151ccccccccccc50100000000000000bbb00000000bbbbbbbbbb05555555555555555a5a10111d6751111ffff9f9999942422222249aaaaaaa45e44eeeeeee5c551dccccccccccd10100000000000000bb00000000bbbbbbbbbb0555555555555555a50011110d67511110ff9f999999942422222244aaaaa45e44eeeeeeeee51d11ccccccccccc01010000000000000bb00000000bbbbbbbbb05555555555555a5a5a0111110d67511110fff999999944422222222244442ee544eeeeeeeeee51d1dcccccccccc101010100000000000b00000000bbbbbbbbb0555555555555a5a5a01111111115511100f9999999944424222224444452eee44eeeeeeeeeefd1ddd3ccccccccc110101010100000000b00000000bbbbbbbbb055555555555a5a5aa0011111111151100199999999494242222449aaaaa42ee44eeeeeeeeeeff5ddcccccccc665111110101010100000b00000000bbbbbbbbb055555555a5a5aaaaaa001111111111005999999999944424224499aaaaaaa2e444eeeeeeeefffd15dcccccc67d1111111110101010000b00000000bbbbbbbbb05a5a5a5a5a5aaaaaaaa000111111000d9999999999444242244999aaaaaaaa2444eeeeeeef7e7dc55dccccccd11111111111110101000b00000000bbbbbbbbb0a5a5a5a5aaaaaaaafffff00000000159999999999444242224999aaaaaaaaa42444eeeee77e77dccdddddddd111111111111111111100b00000000bbbbbbbb0a5aaaaaaaaaaafafffffffff0000159999999999944444242449aaaaaaaaaaaf24ee4eeeffef76ccccccccc1c111111111111111111111000000000bbbbbbbb0aaaaaaaafafafffffffff9ffff99999999999999494442422444aaaaaaaaaaaf524eeeeeef776dcccccccccc1c11111111111111111111000000000bbbbbbbb0aaaaafafaaafffffffff9f999999999999999494944424222444aaaaaaaafaaf5ee44eeef776dcccccccccc1c1c1111111111111111111000000000bbbbbbbb0fafafafafafffffff9f9f99999999999999949494442424224444aaaaaaffaff5eee5deee6ddcdcccccccccc1c1c111111111111111111000000000bbbbbbbb0afafafffffffff9f9f9f9999999999999994944444442422224449aaaaffaf7de2eeeeeddddddcdcccccccccccc1c1c111111111111111000000000bbbbbbbb0fffffffffff9f9f9f99999999999999949494444444242222224999aaaaaf7622e2eeeeddd5dddcdcccccccccccc1c1c11111111111111000000000bbbbbbb0fffffffffff9f9f999999999999999494949444444424222222244aaaaaaf762222e2eeeddddddddcccccccccccccc1c1c1111111111111100000000bbbbbbb0fffff9ffff9f9999999999999994949494944444442424222222224aaafff62222e2eeeeeddddddcdcccccccccccccc1c1c111111111111100000000bbbbbbb0fffffff9f9f99999999999994949494444444444444242222222222222222222222e2eeeeeddddddcdcccccccccccccccc1c1c111111111100000000bbbbbbb09f9f9f9f999999999999999494949444444444444424222222222222222222222222e2eeeedddddddcccccccccccccccccc1c1c11111111100000000bbbbbbb099f9f9999999999999994949494944444444444442422222222222222222222222222e2eeededdddcdcccccccccccccccccccc1c1111111100000000bbbbbb099999999999999999999494949444444444444444242222222222222222222222222222e2eeededdddcdcccccccccccccccccccc1c111111100000000bbbbbb0999999999999999994949494944444444444444424242222222222222222222222222222eeeeeddddddcdcccccccccccccccccccc1c11111100000000bbbbbb05999999999994449494949494444444444444442424222222222222222222222222222222eeeeeddddddcccccccccccccccccccccc111111100000000bbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000'
	
	-- local x = 0
	-- local y = 0
	-- for i = 1, #actual do
	-- 	if actual[i] != ' ' then
	-- 		pset(x, y, mymap[actual[i]])
	-- 	end
	-- 	x += 1
	-- 	if x > 127 then
	-- 		x = 0
	-- 		y += 1
	-- 	end
	-- end

	palt(0, false)

	 sspr(17,0,128,21,17, 0)

	 -- Left Bar
	 sspr(18, 0, 14, 96, 18, 0)

	 -- right bar
	 sspr(96, 0, 9, 96, 96, 0)

	 -- bottom console part 1
	 sspr(17, 85, 95, 30, 17, 85)

	 -- bottom console part 2
	 sspr(0, 96, 128, 32, 0, 96)

	

end

function draw_joystick()
  local buttons = {
    ['xunpressed'] = {
      x = 48,
      y = 32,
      width = 16,
      height = 16,
      -- cx = 8,
      -- cy = 21
    },
    ['xpressed'] = {
      x = 64,
      y = 32,
      width = 16,
      height = 16,
      -- cx = 8,
      -- cy = 21
    }
  }
  local controls = {
    ['neutral'] = {
      x = 0,
      y = 0,
      width = 17,
      height = 30,
      cx = 8,
      cy = 21
    },
    ['left'] = {
      x = 105,
      y = 32,
      width = 32,
      height = 26,
      cx = 119,
      cy = 52
    },
    ['right'] = {
      x = 107,
      y = 60,
      width = 32,
      height = 26,
      cx = 115,
      cy = 80
    },
    ['up'] = {
      x = 0,
      y = 32,
      width = 17,
      height = 30,
      cx = 8,
      cy = 55
    },
    ['down'] = {
      x = 0,
      y = 64,
      width = 18,
      height = 28,
      cx = 8,
      cy = 84
    }
  }

  local dir = 'neutral'
  if btn(0) then
    dir = 'left'
  elseif btn(1) then
    dir = 'right'
  elseif btn(2) then
    dir = 'up'
  elseif btn(3) then
    dir = 'down'
  end

  local ctrl = controls[dir]
  palt(11, true)
  palt(0, false)
  local xoff = ctrl.cx - ctrl.x
  local yoff = ctrl.cy - ctrl.y
  sspr(
    ctrl.x, 
    ctrl.y, 
    ctrl.width, 
    ctrl.height,
    38-xoff, 109-yoff)

  local xbut = nil
  if btn(5) then
    xbut = buttons['xpressed']
  else
    xbut = buttons['xunpressed']
  end
  sspr(
    xbut.x,
    xbut.y,
    xbut.width,
    xbut.height,
    58,
    109
    )

  local zbut = nil
  if btn(4) then 
    zbut = buttons['xpressed']
  else
    zbut = buttons['xunpressed']
  end
  sspr(
    zbut.x,
    zbut.y,
    zbut.width,
    zbut.height,
    60,
    97
    )

  palt()
end

function _draw()

	local old_draw_state = {}
	for i = 0x5f00, 0x5f3f do
		add(old_draw_state, peek(i))
		-- poke(i, 0)
		-- TODO set draw state to sensible default
	end

	if old_draw then
		-- Restore original sprite sheet
		memcpy(0x0000, 0x4300, 8192)
		old_draw()

	end
	-- if true then return end
	-- local cornerX, cornerY = 31, 32-8-1
	poke(0x5f54, 0x60)
	palt(0,false)

	-- TODO
	camera()
	-- This makes the minimap
	local minimapY = 21
	sspr(0,0,128,128, 32,minimapY,64,64) 
	-- rectfill(0,0,128,minimapY,13)
	-- rectfill(0,0,17,96,13)
	-- rectfill(105, 18, 128, 92, 13)
	-- rectfill(0,0,128,minimapY,13)
	rectfill(0,0,32,128,13)
	rectfill(96,0,128,128,13)

	palt()

	-- rectfill(0,0,24,128,0)
	-- rectfill(128 - 24-1,0,128,128,0)

	poke(0x5f54, 0x00)
	-- Restore the picade sprite sheet
	memcpy(0x0000, 0x8000, 8192)
	draw_header()
	draw_joystick()

	-- for i = 0, 7 do
	-- 	rect(cornerX-i, cornerY-i, cornerX+i+64, cornerY+i+64,7)
	-- end

	for i = 0x5f00, 0x5f3f do
		local nothing = nil
		-- poke(i, old_draw_state[i-0x5f00+1])
		-- add(old_draw_state, peek(i))
	end

	pal(11,13,1)
	-- memcpy(0x8000, 0x6000, 8192)
end
-- End Here