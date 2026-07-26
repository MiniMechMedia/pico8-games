-- the olympian: engine (fiber2)
-- single-cart vn engine. images live in oly_imgN.p8 data carts,
-- px9-compressed, reloaded to 0x8000 and decompressed into sprite ram.

bgc='\^#'  -- solid-background text mode

ename={'the hearth','the torch','the mountain','the ash','the dream','the chair','the hound'}
mstart={[0]=0,[1]=8,[2]=16,[3]=24}

function node(id,items)
	return {id=id,items=items}
end

-- ---------- px9 decompress (zep & co, v10) ----------
function px9_decomp(x0,y0,src,vget,vset)
	local function vlist_val(l,val)
		local v,i=l[1],1
		while v!=val do
			i+=1
			v,l[i]=l[i],v
		end
		l[1]=val
	end
	local function getval(m)
		local res=$src >> src%1*8 << 32-m >>> 16-m
		src+=m>>3
		return res
	end
	local function gnp(n)
		local bits=0
		repeat
			bits+=1
			local vv=getval(bits)
			n+=vv
		until vv<(1<<bits)-1
		return n
	end
	local w_1,h_1,eb,el,pr,splen,predict=
		gnp"0",gnp"0",gnp"1",{},{},0
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
			local l=pr[a] or {unpack(el)}
			pr[a]=l
			local v=l[predict and 1 or gnp"2"]
			vlist_val(l,v)
			vlist_val(el,v)
			vset(x,y,v)
		end
	end
end

-- ---------- images ----------
cur_img=nil
cur_pal=nil

function show_img(name)
	local d=img_index[name]
	if not d then
		cur_img=nil
		return
	end
	reload(0x8000,d[2],d[3],'oly_img'..d[1]..'.p8')
	px9_decomp(0,0,0x8000,sget,sset)
	cur_pal=split(d[4])
	cur_img=name
end

function apply_pal()
	if cur_pal then
		for i=1,16 do
			local v=cur_pal[i] or 0
			pal(i-1,v<16 and v or 112+v,1)
		end
	else
		for i=0,15 do
			pal(i,i,1)
		end
	end
end

-- ---------- text helpers ----------
function wwrap(s,w)
	w=w or 31
	local ret,line,linelen='','',0
	for wrd in all(split(s,' ',false)) do
		local wl=0
		for i=1,#wrd do
			if (ord(wrd,i)>15) wl+=1  -- skip control codes
		end
		if linelen>0 and linelen+wl+1>w then
			ret..=line..'\n'
			line,linelen=wrd,wl
		else
			line=linelen>0 and line..' '..wrd or wrd
			linelen+=wl+(linelen>0 and 1 or 0)
		end
	end
	return ret..line
end

function parse_choice(s)
	local parts=split(s,' ',false)
	local c={nd=sub(parts[1],2),txt=''}
	for i=2,#parts do
		local p=parts[i]
		if #p>0 and sub(p,1,1)=='?' and c.txt=='' then
			c.guard=sub(p,2)
		elseif #p>0 and sub(p,1,1)=='!' and c.txt=='' then
			local kv=split(sub(p,2),'=')
			c.ak,c.av=kv[1],kv[2]
		elseif #p>0 or c.txt!='' then
			c.txt=c.txt=='' and p or c.txt..' '..p
		end
	end
	return c
end

-- ---------- game state ----------
S={}          -- story vars: st, cn, gf
mode='title'  -- title | story
glitch=0
fadev=0       -- >0 fading out, <0 fading in (abs = step 0..8)
fadecb=nil
end_banner=nil
cur_music=nil

function set_music(n)
	if n=='-' then
		music(-1)
		cur_music=nil
	elseif cur_music!=n then
		music(mstart[n] or 0)
		cur_music=n
	end
end

-- guards: '?x' any of st/cn/gf equals x, '?k=v' S[k]==v, '?!k' S[k] unset
function guard_ok(g)
	if (not g) return true
	if (sub(g,1,1)=='!') return not S[sub(g,2)]
	local kv=split(g,'=')
	if (#kv==2) return S[kv[1]]==kv[2]
	return S.st==g or S.cn==g or S.gf==g
end

-- interpreter state
nodes={}
items=nil
pc=0
shown={}      -- lines revealed on current page: {txt=..., done=bool}
tstate='idle' -- typing|pause|page|choice|end|idle
keepimg=false
choices=nil
ci=1
rv=0          -- chars revealed of last line
linedelay=0
blipt=0

function goto_node(id)
	if id=='title' then
		fade_to(function()
			mode='title'
			set_music(0)
			show_img('cover')
			end_banner=nil
		end)
		return
	end
	fade_to(function()
		items=nodes[id]
		assert(items,'no node: '..id)
		mode='story'
		pc=0
		shown={}
		choices=nil
		end_banner=nil
		cur_img=nil
		cur_pal=nil
		linedelay=0
		tstate='typing'
	end)
end

function fade_to(cb)
	fadev=1
	fadecb=cb
end

function newpage()
	shown={}
	end_banner=nil
	if not keepimg then
		cur_img=nil
		cur_pal=nil
	end
end

-- resolve branch tables; 'd' = default when key unset/unmatched
function resolve(it)
	if type(it)=='table' and it.br then
		return it[S[it.br]] or it.d or it.rev or it.dre or it.riv
			or it.er or it.en or it.hi or it.open or it.burn or ''
	end
	return it
end

-- process items until we hit a text line or wait state
function step()
	while true do
		pc+=1
		local it=items[pc]
		if it==nil then
			tstate='end'
			return
		end
		it=resolve(it)
		local c1=sub(it,1,1)
		if it=='#' or it=='#k' then
			keepimg=it=='#k'
			tstate='page'
			return
		elseif it=='~' then
			tstate='pause'
			return
		elseif c1=='~' then
			local c2=sub(it,2,2)
			if c2=='g' then
				glitch=14
				sfx(4)
			elseif c2=='m' then
				set_music(tonum(sub(it,3)) or '-')
			elseif c2=='e' then
				local n=tonum(sub(it,3))
				end_banner=n
				dset(0,dget(0)|1<<(n-1))
			end
		elseif c1=='@' then
			show_img(sub(it,2))
		elseif c1=='*' then
			-- gather choice block
			choices={}
			pc-=1
			while true do
				local nx=items[pc+1]
				if type(nx)=='string' and sub(nx,1,1)=='*' then
					pc+=1
					local c=parse_choice(nx)
					if (guard_ok(c.guard)) add(choices,c)
				else
					break
				end
			end
			if #choices==1 and choices[1].txt=='' then
				local c=choices[1]
				choices=nil
				if (c.ak) S[c.ak]=c.av
				goto_node(c.nd)
			else
				ci=1
				tstate='choice'
			end
			return
		else
			-- text line (possibly multi-line after wrap)
			for l in all(split(wwrap(it),'\n')) do
				add(shown,{txt=l,n=0})
			end
			-- mark all but the last as pending too; reveal sequentially
			tstate='typing'
			return
		end
	end
end

function cur_line()
	for i=1,#shown do
		local l=shown[i]
		if (l.n<#l.txt) return l
	end
	return nil
end

function reveal_step(l)
	local n=l.n+1
	if (ord(l.txt,n)==12) n+=1  -- \f takes a param char
	l.n=n
	local c=ord(l.txt,n)
	blipt+=1
	if c and c!=32 and blipt%3==0 and not muteblips then
		sfx(0)
	end
end

function complete_page()
	-- instantly finish all typing up to next wait state
	local l=cur_line()
	while l do
		l.n=#l.txt
		l=cur_line()
	end
end

function upd_story()
	if fadev!=0 then
		return
	end
	local l=cur_line()
	if tstate=='typing' then
		if l then
			if btnp(5) then
				complete_page()
				-- also chew through following text lines instantly
				while tstate=='typing' and cur_line()==nil do
					step()
					complete_page()
				end
				return
			end
			reveal_step(l)
			frame=(frame or 0)+1
			if frame%2==0 then
				local l2=cur_line()
				if (l2) reveal_step(l2)
			end
			linedelay=4
		else
			if linedelay>0 then
				linedelay-=1
			else
				step()
			end
		end
	elseif tstate=='pause' then
		if btnp(5) then
			sfx(3)
			tstate='typing'
			step()
		end
	elseif tstate=='page' then
		if btnp(5) then
			sfx(3)
			fade_to(function()
				newpage()
				tstate='typing'
			end)
		end
	elseif tstate=='choice' then
		local d=(btnp(3) and 1 or 0)-(btnp(2) and 1 or 0)
		if d!=0 then
			local nci=mid(1,ci+d,#choices)
			if (nci!=ci) sfx(1)
			ci=nci
		end
		if btnp(5) then
			sfx(2)
			local c=choices[ci]
			if (c.ak) S[c.ak]=c.av
			choices=nil
			goto_node(c.nd)
		end
	end
end

-- ---------- drawing ----------
fadepat={}
do
	local bayer={0,8,2,10,12,4,14,6,3,11,1,9,15,7,13,5}
	for s=1,8 do
		local p=0
		for i=0,15 do
			if bayer[i+1]>=s*2 then
				p|=1<<(15-i)
			end
		end
		fadepat[s]=p
	end
end

function draw_fade()
	if fadev>0 then
		fillp(fadepat[min(fadev,8)]|0x0.8)
		rectfill(0,0,127,127,0)
		fillp()
		fadev+=1
		if fadev>9 then
			if (fadecb) fadecb()
			fadecb=nil
			fadev=-8
		end
	elseif fadev<0 then
		fillp(fadepat[-fadev]|0x0.8)
		rectfill(0,0,127,127,0)
		fillp()
		fadev+=1
	end
end

function draw_glitch()
	if glitch>0 then
		glitch-=1
		for i=1,5 do
			local y=flr(rnd(128))
			local off=flr(rnd(8))*2+2
			memcpy(0x6000+y*64,0x6000+y*64+off,64-off)
		end
		if rnd(1)<.5 then
			pal(flr(rnd(15))+1,({8,9,10,7})[flr(rnd(4))+1],1)
		end
	end
end

function draw_story()
	cls()
	apply_pal()
	if cur_img then
		palt(0,false)
		spr(0,0,0,16,16)
		palt()
	end
	local y=3
	for i=1,#shown do
		local l=shown[i]
		if l.n>0 then
			print(bgc..sub(l.txt,1,l.n),2,y,7)
		end
		y+=7
	end
	if tstate=='choice' and choices then
		y+=2
		for i=1,#choices do
			local pre=i==ci and '> ' or '  '
			local col=i==ci and 7 or 6
			print(bgc..pre..choices[i].txt,4,y,col)
			y+=8
		end
	end
	if (tstate=='pause' or tstate=='page') and t()%1<.6 then
		print(bgc..'\151',118,121,5)
	end
	if end_banner then
		rectfill(0,110,127,118,0)
		local s='ending '..end_banner..'/7: '..ename[end_banner]
		print(s,64-#s*2,112,9)
	end
	draw_glitch()
	draw_fade()
end

-- ---------- title ----------
embers={}
function upd_title()
	if fadev!=0 then
		return
	end
	if btnp(5) then
		sfx(2)
		S={}
		goto_node('intro')
	end
	if #embers<28 and rnd(1)<.3 then
		add(embers,{x=rnd(128),y=130,vy=-.2-rnd(.5),ph=rnd(1)})
	end
	for e in all(embers) do
		e.y+=e.vy
		e.x+=cos(t()/3+e.ph)*.2
		if (e.y<-2) del(embers,e)
	end
end

function ember_col()
	-- pick a warm slot from the cover palette, else default 9
	if cur_pal then
		for i=16,1,-1 do
			local v=cur_pal[i]
			if v==9 or v==8 or v==10 or v==24 or v==25 or v==30 then
				return i-1
			end
		end
	end
	return 9
end

function draw_title()
	cls()
	apply_pal()
	if cur_img then
		palt(0,false)
		spr(0,0,0,16,16)
		palt()
	end
	local ec=ember_col()
	for e in all(embers) do
		pset(e.x,e.y,t()*4%2<1 and ec or 5)
	end
	print(bgc..'\^w\^tthe olympian',12,14,7)
	print(bgc..'a sequel to the titan',22,30,6)
	if t()%1.2<.7 then
		print(bgc..'press \151',48,96,7)
	end
	local found=0
	local m=dget(0)
	for i=0,6 do
		if (m&1<<i>0) found+=1
	end
	if found>0 then
		print(bgc..'endings found: '..found..'/7',2,121,5)
	end
	if found==7 then
		print(bgc..'the titan is satisfied',2,114,9)
	end
	draw_fade()
end

-- ---------- main ----------
function _init()
	cartdata('mmm_olympian_v1')
	menuitem(1,'back to title',function()
		goto_node('title')
	end)
	local nl=story_nodes()
	for n in all(nl) do
		nodes[n.id]=n.items
	end
	mode='title'
	show_img('cover')
	set_music(0)
	fadev=-8
end

function _update()
	if mode=='title' then
		upd_title()
	else
		upd_story()
	end
end

function _draw()
	if mode=='title' then
		draw_title()
	else
		draw_story()
	end
end
