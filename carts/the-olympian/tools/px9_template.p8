pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- px9 compress job cart
-- gfx section holds the 16-color indexed image.
-- compresses spritesheet -> 0x8000, prints hex between markers, exits.

function px9_comp(x0,y0,w,h,dest,vget)
	local dest0=dest
	local function vlist_val(l, val)
		local v,i=l[1],1
		while v!=val do
			i+=1
			v,l[i]=l[i],v
		end
		l[1]=val
		return i
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
	local pr={}
	local dat={}
	for y=y0,y0+h-1 do
		for x=x0,x0+w-1 do
			local v=vget(x,y)
			local a=y>y0 and vget(x,y-1) or 0
			local l=pr[a] or {unpack(el)}
			pr[a]=l
			add(dat,vlist_val(l,v))
			vlist_val(el, v)
		end
	end
	local nopredict
	local pos=1
	while pos <= #dat do
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

hx="0123456789abcdef"
function _init()
	local clen = px9_comp(0,0,128,128,0x8000,sget)
	printh("!!blobstart "..clen)
	local line=""
	for i=0,clen-1 do
		local b=peek(0x8000+i)
		line ..= sub(hx,b\16+1,b\16+1)..sub(hx,b%16+1,b%16+1)
		if #line >= 128 then
			printh(line)
			line=""
		end
	end
	if (#line>0) printh(line)
	printh("!!blobend")
	extcmd("shutdown")
end
__gfx__
