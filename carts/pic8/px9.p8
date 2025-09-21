pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- px9 data compression v10
-- by zep & co.
--
-- changelog:
--
-- v11:
--  @felice: removed unneeded
--  brackets -> 214 tokens
--
-- v10:
--  @pancelor
--  ★ remove cruft
--  ★ clever getval() tricks
--  ★ fix low-entropy bug
--  215 tokens
--  @zep: added tests tab 3
--
-- v9:
--  @pancelor
--  ★ redo bitstream order
--  234 tokens (but ~4% slower)
--
-- v8:
--  @pancelor
--  ★ smaller vlist initialization
--  241 tokens
--
-- v7:
--  smaller vlist_val by @felice
--  7b -> 254 tokens (fastest)
--  7a -> 247 tokens (smallest)
--
-- v6:
--  smaller vlist_val by @p01
--  -> 258 tokens
--
-- v5:
--  fixed bug found by @icegoat
--  262 tokens (the bug was caused by otherwise redundant code!)
--
-- v4:
--  @catatafish
--  ★ smaller decomp
--
--  @felice
--  ★ fix bit flush at end
--  ★ use 0.2.0 functionality
--  ★ even smaller decomp
--  ★ some code simpler/cleaner
--  ★ hey look, a changelog!
--
-- v3:
--  @felice
--  ★ smaller decomp
--
-- v2:
--  @zep
--  ★ original release
--
--[[

	features:
	★ 273 token decompress
	★ handles any bit size data
	★ no manual tuning required
	★ decent compression ratios


	██▒ how to use ▒██

	1. compress your data

		px9_comp(source_x, source_y,
			width, height,
			destination_memory_addr,
			read_function)

		e.g. to compress the whole
		spritesheet to the map:

		px9_comp(0,0,128,128,
			0x2000, sget)

	…………………………………
	2. decompress

		px9_decomp(dest_x, dest_y,
			source_memory_addr,
			read_function,
			write_function)

		e.g. to decompress from map
		memory space back to the
		screen:

		px9_decomp(0,0,0x2000,
			pget,pset)

		…………………………………

		(see example below)

		note: only the decompress
		code (tab 1) is needed in
		your release cart after
		storing compressed data.

]]

function _init()

	-- test: compress from
	-- spritesheet to map, and
	-- then decomp back to screen

	cls()
	print("compressing..",5)
	flip()

	w=128 h=128
	raw_size=(w*h+1)\2 -- bytes

	ctime=stat(1)

	-- compress spritesheet to map
	-- area (0x2000) and save cart

	clen = px9_comp(
		0,0,
		w,h,
		0x2000,
		sget)

	ctime=stat(1)-ctime

	--cstore() -- save to cart

	-- show compression stats
	print("                 "..(ctime/30).." seconds",0,0)
	print("")
	print("compressed spritesheet to map",6)
	printh('start bytes')
	for i = 0x2000, 0x2000 + clen do
		printh(peek(i))
	end
	printh('end bytes')

	ratio=tostr(clen/raw_size*100)
	print("bytes: "
		..clen.." / "..raw_size
		.." ("..sub(ratio,1,4).."%)"
		,12)
	print("")
	print("press ❎ to decompress",14)

	memcpy(0x7000,0x2000,0x1000)

	-- wait for user
	repeat until btn(❎)

	print("")
	print("decompressing..",5)
	flip()

	-- save stats screen
	local cx,cy=cursor()
	local sdata={}
	for a=0x6000,0x7ffc do
		sdata[a]=peek4(a)
	end

	dtime=stat(1)

	-- decompress data from map
	-- (0x2000) to screen

	px9_decomp(0,0,0x2000,pget,pset)

	dtime=stat(1)-dtime

	-- wait for user
	repeat until btn(❎)

	-- restore stats screen
	for a,v in pairs(sdata) do
		poke4(a,v)
	end

	-- add decompression stats
	print("                 "..(dtime/30).." seconds",cx,cy-6,5)
	print("")

end

-->8
-- px9 decompress

-- x0,y0 where to draw to
-- src   compressed data address
-- vget  read function (x,y)
-- vset  write function (x,y,v)

function
	px9_decomp(x0,y0,src,vget,vset)

	local function vlist_val(l, val)
		-- find position and move
		-- to head of the list

--[ 2-3x faster than block below
		local v,i=l[1],1
		while v!=val do
			i+=1
			v,l[i]=l[i],v
		end
		l[1]=val
--]]

--[[ 7 tokens smaller than above
		for i,v in ipairs(l) do
			if v==val then
				add(l,deli(l,i),1)
				return
			end
		end
--]]
	end

	-- read an m-bit num from src
	local function getval(m)
		-- $src: 4 bytes at flr(src)
		-- >>src%1*8: sub-byte pos
		-- <<32-m: zero high bits
		-- >>>16-m: shift to int
		local res=$src >> src%1*8 << 32-m >>> 16-m
		src+=m>>3 --m/8
		return res
	end

	-- get number plus n
	local function gnp(n)
		local bits=0
		repeat
			bits+=1
			local vv=getval(bits)
			n+=vv
		until vv<(1<<bits)-1
		return n
	end

	-- header

	local
		w_1,h_1,      -- w-1,h-1
		eb,el,pr,
		splen,
		predict
		=
		gnp"0",gnp"0",
		gnp"1",{},{},
		0
		--,nil
	printh('w_1: '..w_1)
	printh('h_1: '..h_1)
	for i=1,gnp"1" do
		add(el,getval(eb))
	end
	for y=y0,y0+h_1 do
		for x=x0,x0+w_1 do
			splen-=1

			if splen<1 then
				splen,predict=gnp"1",not predict
			end

			local a=y>y0 and vget(x,y-1) or 0

			-- create vlist if needed
			local l=pr[a] or {unpack(el)}
			pr[a]=l

			-- grab index from stream
			-- iff predicted, always 1

			local v=l[predict and 1 or gnp"2"]

			-- update predictions
			vlist_val(l, v)
			vlist_val(el, v)

			-- set
			vset(x,y,v)
		end
	end
end

-->8
-- px9 compress

-- x0,y0 where to read from
-- w,h   image width,height
-- dest  address to store
-- vget  read function (x,y)

function
	px9_comp(x0,y0,w,h,dest,vget)

	local dest0=dest

	local function vlist_val(l, val)
		-- find position and move
		-- to head of the list

--[ 2-3x faster than block below
		local v,i=l[1],1
		while v!=val do
			i+=1
			v,l[i]=l[i],v
		end
		l[1]=val
		return i
--]]

--[[ 8 tokens smaller than above
		for i,v in ipairs(l) do
			if v==val then
				add(l,deli(l,i),1)
				return i
			end
		end
--]]
	end

	local bit=1
	local byte=0
	local function putbit(bval)
		if (bval>0) byte+=bit
		poke(dest, byte) bit<<=1
		if (bit==256) then
			bit=1 byte=0
			dest += 1
		end
	end

	local function putval(val, bits)
		for i=0,bits-1 do
			putbit(val>>i&1)
		end
	end

	local function putnum(val)
		local bits = 0
		repeat
			bits += 1
			local mx=(1<<bits)-1
			local vv=min(val,mx)
			putval(vv,bits)
			val -= vv
		until vv<mx
	end


	-- first_used

	local el={}
	local found={}
	local highest=0
	for y=y0,y0+h-1 do
		for x=x0,x0+w-1 do
			c=vget(x,y)
			if not found[c] then
				found[c]=true
				add(el,c)
				highest=max(highest,c)
			end
		end
	end

	-- header

	local bits=1
	while highest >= 1<<bits do
		bits+=1
	end

	putnum(w-1)
	putnum(h-1)
	putnum(bits-1)
	putnum(#el-1)
	for i=1,#el do
		putval(el[i],bits)
	end


	-- data

	local pr={} -- predictions

	local dat={}

	for y=y0,y0+h-1 do
		for x=x0,x0+w-1 do
			local v=vget(x,y)

			local a=y>y0 and vget(x,y-1) or 0

			-- create vlist if needed
			local l=pr[a] or {unpack(el)}
			pr[a]=l

			-- add to vlist
			add(dat,vlist_val(l,v))

			-- and to running list
			vlist_val(el, v)
		end
	end

	-- write
	-- store bit-0 as runtime len
	-- start of each run

	local nopredict
	local pos=1

	while pos <= #dat do
		-- count length
		local pos0=pos

		if nopredict then
			while dat[pos]!=1 and pos<=#dat do
				pos+=1
			end
		else
			while dat[pos]==1 and pos<=#dat do
				pos+=1
			end
		end

		local splen = pos-pos0
		putnum(splen-1)

		if nopredict then
			-- values will all be >= 2
			while pos0 < pos do
				putnum(dat[pos0]-2)
				pos0+=1
			end
		end

		nopredict=not nopredict
	end

	if(bit>0) dest+=1 -- flush

	return dest-dest0
end

-->8
-- tests
-- uncomment run_tests() at 
-- bottom of this tab. each
-- test compresses video and
-- checks crc matches.

--[[
expected sizes
blank:    21 (0.0026)
circ:    254 (0.0310)
lines:  2109 (0.2574)
dots:   2075 (0.2533)
lunch:  1275 (0.1556)
noise: 12819 (1.5648)
noise1: 3277 (0.4000)
]]

function vid_crc()
	local res=109
	for i=0x6000,0x7fff,4 do
		res ^^= 0x9e13.48b1
		res += $i
		res <<>= 5
		res *= 103.11
	end
	return res
end

-- compress whatever is on the
-- screen and check crc matches
function vid_test(name)

crc0=vid_crc()
len=px9_comp(0,0,128,128,
	0x8000,pget)
printh(name..": "..len..
 " ("..(len/8192)..")")
cls()
px9_decomp(0,0,0x8000,pget,pset)

crc1=vid_crc()
assert(crc0==crc1)
end


function run_tests()
	
	printh("--- px9 tests ---")
	
	cls(2)
	vid_test("blank")
	
	-- circles
	cls()circfill(64,64,32,12)
	vid_test("circ")
	
	--lines
	cls()
	for i=0,128,4 do
	line(i,0,0,128-i,8+i/8)
	line(i,128,128,128-i,8+i/8)
	end
	vid_test("lines")
	
	--dots
	cls()srand()
	for i=0,2000 do
		circfill(rnd(128),rnd(128),rnd(16),rnd(16))
	end
	vid_test("dots")
	
	cls()spr(0,0,0,16,16)
	vid_test("lunch")
	
	-- noise
	cls()
	for i=0x6000,0x7fff do
		poke(i, rnd(256))
	end
	vid_test("noise")
	
	-- 1-bit noise
	cls()
	for i=0x6000,0x7fff do
		poke(i, rnd(2)+(rnd(2)\1)*16)
	end
	vid_test("noise1")
	
	-- fuzz
	-- (would be more meaningful
	-- with more variation in
	-- data characteristics)
	srand()
	
	--for j=0,500 do
	for j=0,4 do
	cls(rnd(16))
	for i=0,rnd(4000) do
		circfill(rnd(128),rnd(128),rnd(16),rnd(16))
	end
	for i=0,rnd(4000) do
		pset(rnd(128),rnd(128),rnd(16),rnd(16))
	end
	vid_test("fuzz"..j)
	end
	
	color(7)
	cls()
	stop("ok")
	
end



-- 0000000000000000000000000000000000000000000000000000000000000000
-- 0000000000000000000000000000000000000000000000000000000000000000
-- 0000000000000000000000000000000000000000000000000000000000000000
-- 0000000000000000000000000000000000000000000000000000000000000000
-- 0000000000000000000000000000000000000000000000000000000000000000
-- 0000000000000000000000000000008000000000000000000000000000000000
-- 0000000000000000000000000000007s00000000000000000000000000000000
-- 000000000000000000000000000000d700000000000000000000000000000000
-- 000000000000000000000000000000b700000000000000000000000000000000
-- 00000000000000000000000000000b0700000000000000000000000000000000
-- 0000000000000000000000000000079700000000000000000000000000000000
-- 0000000000000000000000000000077c00000000000000000000000000000000
-- 0000000000000000000000000000077b00000000000000000000000000000000
-- 0000000000000000000000000000077790000000000000000000000000000000
-- 00000000000000000000000000000777b0000000000000000000000000000000
-- 00000000000000000000000000000777s0000000000000000000000000000000
-- 0000000000000000000000000000077d70000000000000000000000000000000
-- 0000000000000000000000000000077b70000000000000000000000000000000
-- 000000000000000000000000000007b070000000000000000000000000000000
-- 000000000000000000000000000007s070000000000000000000000000000000
-- 00000000000000000000000000000d7070000000000000000000000000000000
-- 00000000000000000000000000000b7070000000000000000000000000000000
-- 0000000000000000000000000000b07070000000000000000000000000000000
-- 0000000000000000000000000000797070000000000000000000000000000000
-- 000000000000000000000000000077c070000000000000000000000000000000
-- 000000000000000000000000000077b070000000000000000000000000000000
-- 0000000000000000000000000000777970000000000000000000000000000000
-- 00000000000000000000000000007777c0000000000000000000000000000000
-- 000000000000000000000000000077770s000000000000000000000000000000
-- 00000000000000000000000000007777d7000000000000000000000000000000
-- 0000000000000000000000000000777787000000000000000000000000000000
-- 000000000000000000000000000077777s000000000000000000000000000000
-- 0000000000000000000000000000777770800000000000000000000000000000
-- 00000000000000000000000000007777707s0000000000000000000000000000
-- 0000000000000000000000000000777770d70000000000000000000000000000
-- 0000000000000000000000000000777770b70000000000000000000000000000
-- 0000000000000000000000000000777770s70000000000000000000000000000
-- 000000000000000000000000000077777d770000000000000000000000000000
-- 00000000000000000000000000007777d0770000000000000000000000000000
-- 00000000000000000000000000007777b0770000000000000000000000000000
-- 00000000000000000000000000007777s0770000000000000000000000000000
-- 0000000000000000000000000000777d70770000000000000000000000000000
-- 0000000000000000000000000000777b70770000000000000000000000000000
-- 0000000000000000000000000000777s70770000000000000000000000000000
-- 000000000000000000000000000077d770770000000000000000000000000000
-- 000000000000000000000000000077b770770000000000000000000000000000
-- 00000000000000000000000000007b0770770000000000000000000000000000
-- 00000000000000000000000000007s0770770000000000000000000000000000
-- 0000000000000000000000000000d70770770000000000000000000000000000
-- 0000000000000000000000000000b70770770000000000000000000000000000
-- 000000000000000000000000000b070770770000000000000000000000000000
-- 0000000000000000000000000007970770770000000000000000000000000000
-- 00000000000000000000000000077c0770770000000000000000000000000000
-- 00000000000000000000000000077b0770770000000000000000000000000000
-- 0000000000000000000000000007779770770000000000000000000000000000
-- 0000000000000000000000000007777c70770000000000000000000000000000
-- 00000000000000000000000000077770s0770000000000000000000000000000
-- 000000000000000000000000000777700d770000000000000000000000000000
-- 0000000000000000000000000007777008770000000000000000000000000000
-- 0000000000000000000000000007777007s70000000000000000000000000000
-- 00000000000000000000000000077770070d0000000000000000000000000000
-- 00000000000000000000000000077770070b0000000000000000000000000000
-- 0000000000000000000000000007777007b00000000000000000000000000000
-- 0000000000000000000000000007777007790000000000000000000000000000

--run_tests()

__gfx__
dddddddd111eee110000000011111111dddddddd11111111dddddddd11111111
dddeeedd11eeeee1d000d000111ee111dddddddd11eeee11dddeeddd11111111
ddeeeedd1e7eeeeedd00000011eeee11dddeeddd117eee11ddeeeedd11111111
ddeeeeed1e7eeeeedd00000d11eeee11ddeeeedd1eeeeee1ddeeeedd1117e111
ddeeeeed1eeeeeeed000000d11eee211dddeeedd11eeee11ddeee2dd111ee111
dde22e2d1eeeeeeedd00002d11eeee21dd22222d11222e21ddeeee2d11222221
d4555554142222e4d455055414555554d455555414555554d455555414555554
d44444441eeeeeeed444044414444444d444444414444444d444444414444444
14fffff4d4fffff414fffff4d4fffff414fffff4d4fffff414fffff4d4fffff4
11fffff1ddfffffd11fffff1ddfffffd11fffff1ddfffffd11fffff1ddfffffd
11fffff1ddfffffd11fffff1ddfffffd11fffff1ddfffffd11fffff1ddfffffd
114fff41dd4fff4d114fff41dd4fff4d114fff41dd4fff4d114fff41dd4fff4d
114fff41dd4fff4d114fff41dd4fff4d114fff41dd4fff4d114fff41dd4fff4d
11111111dddddddd11111111dddddddd11111111dddddddd11111111dddddddd
11111111dddddddd18000000dddddddd11111111dddddddd11111111dddddddd
11111111dddddddd18000000dddddddd11111111dddddddd11111111dddddddd
dddddddd11111111dddddddd11111111dddddddd11111111dddddddd11111111
dddddddd11111111dddddddd11111111dddddddd11111111dddddddd11111111
dddddddd11111111dddddddd11111111dddddddd11111111dddddddd11111111
dddddddd11111111dddddddd11111111dddddddd11111111dddddddd11111111
dddddddd11111111dddddddd11111111dddddddd11111111dddddddd11111111
dddddddd11111111dddddddd11111111dddddddd11111111dddddddd11111111
dddddddd11111111dddddddd11111111dddddddd11111111dddddddd11111111
dddddddd11111111dddddddd11111111dddddddd11111111dddddddd11111111
11111111dddddddd11111111dddddddd11111111dddddddd11111111dddddddd
11111111dddddddd11111111dddddddd11111111dddddddd11111111dddddddd
11111111dddddddd11111111dddddddd11111111dddddddd111eee11dddddddd
11111111dddddddd11111111dddddddd11111111dddddddd11eeeee1dddddddd
11111111dddddddd11111111dddddddd11111111dddddddd1e7eeeeedddddddd
11111111dddddddd11111111dddddddd11111111dddddddd1e7eeeeedddddddd
11111111dddddddd11111111dddddddd11111111dddddddd1eeeeeeedddddddd
11eeeee1dddddddd11111111dddddddd11111119dddddddd1eeeeeeedddddddd
dee7eeee11111111dddddddd11111111dddddaaaa1111111dd2222ed11111111
de7eeeee11111111dddddddd11111111dddd9aaaa9111111deeeeeee11111111
deeeeeee11111111dddddddd11111111dddd999999111111dddddddd11111111
deeeeeee11111111dddddddd11111111ddddd87181111111dddddddd11111111
de2eee2e11111111dddddddd11111111ddddd88881111111dddddddd11111111
deeeeeee11111111dddddddd11111111dddddddd11111111dddddddd11111111
dddddddd11111111dddddddd11111111dddddddd11111111dddddddd11111111
dddddddd11111111dddddddd11111111dddddddd11111111dddddddd11111111
11111111dddddddd11111111dddddddd11111111dddddddd11111111dddddddd
11111111dddddddd11111111dddddddd111eee11dddddddd11111111dddddddd
11111111dddddddd11111111dddddddd11eeeee1dddddddd11111111dddddddd
11111111dddddddd11111111dddddddd1e7eeeeedddddddd11111111dddddddd
11111111dddddddd11111111dddddddd1e7eeeeedddddddd11111111dddddddd
11111111dddddddd11111111dddddddd1eeeeeeedddddddd11111111dddddddd
11111111dddddddd11111111dddddddd1eeeeeeedddddddd11111111dddddddd
11111111dddddddd11111111dddddddd112222e1dddddddd11111111dddddddd
dddddddd11111111dddddddd11111111deeeeeee11111111dddddddd11111111
dddddddd11111111dddddddd11111111dddddddd11111111dddddddd11111111
dddddddd11111111dddddddd11111111dddddddd11111111dddddddd11111111
dddddddd11111111dddddddd11111111dddddddd11111111dddddddd11111111
dddddddd11111111dddddddd11111111dddddddd11111111dddddddd11111111
dddddddd11111111dddddddd11111111dddddddd11111111dddddddd11111111
dddddddd11111111dddddddd11111111dddddddd11111111dddddddd11111111
dddddddd11111111dddddddd11111111dddddddd11111111dddddddd11111111
11111111dddddddd11111111dddddddd11111111dddddddd11111111dddddddd
11111111dddddddd11111111dddddddd11111111dddddddd11111111dddddddd
11111111dddddddd11111111dddddddd11111111dddddddd11111111dddddddd
11111111dddddddd11111111dddddddd11111111dddddddd11111111dddddddd
11111111dddddddd11111111dddddddd11111111dddddddd11111111dddddddd
11111111dddddddd11111111dddddddd11111111dddddddd11111111dddddddd
11111111dddddddd11111111dddddddd11111111dddddddd11111111dddddddd
11111111dddddddd11111111dddddddd11111111dddddddd11111111dddddddd
