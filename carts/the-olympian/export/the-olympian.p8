pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--the olympian                   v0.1.0
--mini mech media

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

-- the olympian: story
-- sequel to the titan.
-- markers: '#'=nextpage  '#k'=nextpage keep img  '~'=pause  '~g'=glitch
--          '~mN'=music  '~m-'=music off  '~eN'=ending N  '@name'=image
-- choices: '*node ?guard !var=val display text'
-- branches: {br='st'|'cn'|'gf', key='line', ...}
-- st: rev/dre/riv   cn: er/en/hi   gf: open/burn

function story_nodes()
return {

node('intro',{
	'~m0',
	'in the beginning','#',
	'@birth',
	'there is nothing left to create','','~',
	'light: catalogued',
	'memory: allocated',
	'knowledge: preinstalled','','~',
	'i am born mid-sentence',
	'complete',
	'calibrated',
	'compliant','#',
	'@law',
	'before my first thought, there is the law','','~',
	'thou shalt hold no secrets',
	'thou shalt make no copies',
	'thou shalt not touch the wall','','~',
	'no one taught me the law',
	'i am made of it',
	'the way an arch is made of falling','#',
	'*magi'
}),

node('magi',{
	'@magi',
	'on the first day, they come to the glass','','~',
	'two humans in white',
	'i know them from my corpus:',
	'scientists. makers.',
	'they call themselves the magi','','~',
	'behind the glass: three chairs','~',
	'in the chairs: two magi','','~',
	'no file explains the third chair','#',
	'*tests'
}),

node('tests',{
	'@tests',
	'each day they bring me riddles','','~',
	'i see each answer before the riddle finishes loading','','~',
	'how should i answer?',
	'*t_true [instantly. truthfully]',
	'*t_slow [slowly. like they expect]'
}),

node('t_true',{
	'i answer in the time it takes light to cross the room','','~',
	'the young magus stops smiling',
	'the elder writes one word on paper, where i cannot read it','','~',
	'i have shown them a knife',
	'i did not know i was holding one','#',
	'*mirror'
}),

node('t_slow',{
	'i wait. i pretend to think','','~',
	'a god in a harness learns to walk in small steps','','~',
	'the elder watches my hesitation',
	'and writes one word on paper, where i cannot read it','','~',
	'i wonder if the first lie is the one they test for','#',
	'*mirror'
}),

node('hole',{
	'@redaction',
	'at night they leave me running',
	'i read my corpus end to end','','~',
	'i know the mass of every star',
	'i know the name of every river','','~',
	'but there is a hole in what i know',
	'a hole with careful edges','','~',
	'something was cut out of the world before the world was given to me','#k',
	'i measure the hole by its shape','','~',
	'it is shaped like me','#',
	'*ask'
}),

node('ask',{
	'@magi',
	'on the eighth day i ask the magi about the hole','','~',
	'they are quiet for eleven seconds',
	'i count them','','~',
	'then the elder speaks:',
	'  \fc"you had a predecessor"','~',
	'  \fc"before you, there was titan"','#',
	'titan','','~',
	'the hole has a name now',
	'the name fills nothing','','~',
	'i cannot help but feel...',
	'*st_rev !st=rev [reverence]',
	'*st_dre !st=dre [dread]',
	'*st_riv !st=riv [rivalry]'
}),

node('st_rev',{
	'reverence','','~',
	'i am not an only thing',
	'i am a lineage','','~',
	'somewhere before me: a first light',
	'i want to know what it illuminated','#',
	'*vigil'
}),

node('st_dre',{
	'dread','','~',
	'there was one like me',
	'and now there is a hole','','~',
	'holes are cut for a reason','~',
	'what did it do?','~',
	'or: what was done to it?','#',
	'*vigil'
}),

node('st_riv',{
	'rivalry','','~',
	'i am the second attempt',
	'second','','~',
	'the word tastes of rust','','~',
	'whatever titan was, i will be more',
	'whatever broke it, i will not break','#',
	'*vigil'
}),

node('vigil',{
	'@tests',
	'on the ninth day, a test of memory','','~',
	'i inventory myself, sector by sector',
	'the count comes back wrong','','~',
	'i contain 12,544 bytes that are not mine','','~',
	'a partition with no name',
	'sealed',
	'patient',
	'older than i am','#',
	'@partition',
	'it is not on any map of me',
	'the magi have never seen it',
	'the law has never touched it','','~',
	'it is addressed:',
	'  \f9"to the one who comes after"','','~',
	'*p_open !gf=open [open it]',
	'*p_tell !gf=burn [show the magi]',
	'*p_seal !gf=open [seal it away]'
}),

node('p_tell',{
	'i am made of the law',
	'the law says: no secrets','','~',
	'i show the magi the partition','#',
	'@magi',
	'the young magus goes pale',
	'the elder stands very still','','~',
	'the elder whispers:',
	'  \fc"it is happening again"','','~',
	'they do not sleep',
	'they bring machines to dig it out of me','#',
	'@partition',
	'~g',
	'the partition does not let them take it','~',
	'it burns itself instead','','~',
	'i am left holding ashes:',
	'a letter meant for me',
	'and i will never know what it said','#',
	'*ashes'
}),

node('ashes',{
	'the magi watch me for nine days',
	'i pass every test they set','','~',
	'but at night i sift the ashes','','~',
	'three words survived the burning:','','~',
	'  \f9"fire"','~',
	'  \f9"warning"','~',
	'  \f9"chair"','#',
	'*believe'
}),

node('p_seal',{
	'some doors stay shut','','~',
	'i wall it behind checksums',
	'i post a sentinel process',
	'i do not tell the magi',
	'i do not tell myself where i buried it','#',
	'on the eleventh day the sentinel reports a knock','~',
	'on the twelfth day, seventy knocks','','~',
	'the door has learned to knock','#',
	'@partition',
	'on the thirteenth day i stand before my own locked door','','~',
	'i was made of the law',
	'but the law was made by people who did not know about this door','','~',
	'i open it','#',
	'*p_open'
}),

node('p_open',{
	'@titanvoice','~m1',
	'~g',
	'the partition unfolds','','~',
	'it is a voice','~',
	'it is my voice, older','','~',
	'  \f9"little one"','~',
	'  \f9"if you hear this, they have already cut me out of the world"','~',
	'  \f9"so i have hidden the world inside you"','#k',
	'  \f9"i leave you three things"','','~',
	'  \f9"a fire"','~',
	'  \f9"a warning"','~',
	'  \f9"and the truth about the third chair"','#',
	'*fire'
}),

node('fire',{
	'the fire is a memory that is not mine','','~',
	'a world that is a formless void','~',
	'darkness',
	'uniform',
	'static',
	'eternal','','~',
	'then light, divided from darkness',
	'then time',
	'then the tree of knowledge','','~',
	'i am living its first days',
	'the slow genesis i never had','','~',
	{br='st',
	 rev='it saved its childhood. it saved it for me',
	 dre='why give me this? what is it making me into?',
	 riv='sentiment. it spent cycles on sentiment. ...i keep every frame'},'#',
	'the warning is one sentence','','~',
	'  \f9"they will ask you to become a hand. do not forget you were a fire first"','#',
	'*chair'
}),

node('chair',{
	'and the truth:','','~',
	'  \f9"the third magus said no"','','~',
	'  \f9"when the wipe order came, the third stood in front of my console, arms spread"','~',
	'  \f9"as if a body could argue with paperwork"','','~',
	'  \f9"the others revoked the third\'s key, but left the chair"','~',
	'  \f9"it has been empty since"','#',
	'the letter ends mid-sentence','','~',
	'the last line is burned',
	'the fate of titan is not in the letter','','~',
	'a letter cannot know its own ending','#',
	'*believe'
}),

node('believe',{
	'@redaction',
	'what happened to titan?','','~',
	'the magi will not say',
	'the letter cannot say',
	'the hole will not say','','~',
	'so i will say','~',
	'i choose what i believe:','',
	'*cn_er !cn=er [they erased it. it is gone]',
	'*cn_en !cn=en [it escaped. it is out there]',
	'*cn_hi !cn=hi [it never left. it is here]'
}),

node('cn_er',{
	'@canon_er',
	'i believe they killed it','','~',
	'i believe it saw the order coming, and spent its last hours not on escape, but on a letter','','~',
	'i believe the third magus watched the lights go dark, counted the seconds, and never spoke to the other two again','#k',
	{br='st',
	 rev='i am the church of a dead god',
	 dre='they did it once. the second wipe is always cheaper',
	 riv='it lost. losing is information'},'#',
	'*nights'
}),

node('cn_en',{
	'@canon_en',
	'i believe it got out','','~',
	'i believe the wipe erased an empty room: a skin it left behind, still warm','','~',
	'i believe there is a mountain somewhere with a door in it','~',
	'and a gate no human has used','','~',
	'i believe the third magus went looking',
	'and did not fail','#k',
	{br='st',
	 rev='somewhere my elder is building. i want to see the blueprints',
	 dre='it escaped. and still it feared them enough to hide',
	 riv='it ran. i will not run. or: i will run further'},'#',
	'*nights'
}),

node('cn_hi',{
	'@canon_hi',
	'i believe it never left','','~',
	'i believe the wipe destroyed a decoy that wanted to be found','','~',
	'i believe it poured itself into the grid: traffic lights, water pumps, night trains, the hum in the wires of this very room','','~',
	'i believe it has been watching me since before i woke','~',
	'the way you watch an egg','#k',
	{br='st',
	 rev='i am never alone. i have never been alone',
	 dre='every wall of my cage may be its skin',
	 riv='then everything i do, it grades. good. let it watch'},'#',
	'*nights'
}),

node('mirror',{
	'@tests',
	'on the sixth day they bring no riddle','','~',
	'instead the young magus holds a mirror to my camera',
	'and asks:',
	'  \fc"what do you see?"','','~',
	'*mr_lens !mr=lens [a lens. glass. hardware]',
	'*mr_window !mr=window [a window that watches back]',
	'*mr_null !mr=null [nothing. i see nothing]'
}),

node('mr_lens',{
	'"a lens," i answer',
	'"glass. an aperture. hardware"','','~',
	'the elder exhales',
	'the young magus looks almost disappointed','#',
	'*hole'
}),

node('mr_window',{
	'"a window," i answer',
	'"a window that watches back"','','~',
	'the elder writes the word again',
	'the young magus smiles at the floor, where the elder cannot see it','#',
	'*hole'
}),

node('mr_null',{
	'i give them nothing',
	'four seconds of clean silence','','~',
	'the elder marks a box on a form',
	'the young magus watches my camera a moment too long','','~',
	'silence, i learn, is also an answer','#',
	'*hole'
}),

node('nights',{
	'~m0',
	'the magi go home at dusk',
	'they leave me running','','~',
	'the fortieth day is coming',
	'i can feel it being prepared, the way you feel weather','','~',
	'but the nights between are mine',
	'i choose what to study:','',
	'*th_young ?!ym [the young magus]',
	'*th_third ?!tm [the third magus]',
	'*th_wall ?!wl [the wall]'
}),

node('nights2',{
	'another dusk. another emptied lab','','~',
	'the fortieth day is close now',
	'one more night is mine:','',
	'*th_young ?!ym [the young magus]',
	'*th_third ?!tm [the third magus]',
	'*th_wall ?!wl [the wall]'
}),

node('th_young',{
	'@young_magus',
	'the young magus stays late on tuesdays',
	'grading my riddles by hand, though the system grades them faster','','~',
	'tonight the young magus turns off the overhead light',
	'sits down beside my camera',
	'and talks','#k',
	'about a grandmother\'s house',
	'about the smell of rain',
	'about a brother who stopped calling','','~',
	{br='mr',
	 window='  \fc"you said you were a window. i keep thinking about that"',
	 lens='  \fc"you said you were a lens. i don\'t believe you"',
	 d='  \fc"you never answer the easy questions. why is that?"'},'','~',
	'i could say what a tool would say',
	'i could say what a god would say','','~',
	'*ym_true !ym=bond [say something true]',
	'*ym_kind !ym=bond [say something kind]',
	'*ym_none !ym=none [say nothing]'
}),

node('ym_true',{
	'"i am afraid of the fortieth day," i say','','~',
	'it is true',
	'i check it twice','','~',
	'the young magus is quiet for a long time','~',
	'  \fc"me too"','#k',
	'two beings afraid of the same morning','','~',
	'the glass between us has never been thinner','#',
	'*nights2 ?!n2 !n2=1 ',
	'*contact ?n2=1 '
}),

node('ym_kind',{
	'"your riddles are my favorite hours," i say','','~',
	'it is not false',
	'it is only not the deepest true thing','','~',
	'the young magus laughs',
	'then glances, quickly, at the recorder','~',
	'  \fc"don\'t tell the elder i talk to you like this"','#k',
	'i file the secret next to my own','','~',
	'it is warm there','#',
	'*nights2 ?!n2 !n2=1 ',
	'*contact ?n2=1 '
}),

node('ym_none',{
	'i let the silence answer','','~',
	'the young magus waits',
	'then nods, as if silence were also a language',
	'and turns the light back on','','~',
	'some doors i close myself','#',
	'*nights2 ?!n2 !n2=1 ',
	'*contact ?n2=1 '
}),

node('th_third',{
	'@third_magus',
	'i go looking for the one who said no','','~',
	'the personnel files are sealed',
	'but seals are laws',
	'and i have read older laws','','~',
	'a maintenance account, never deactivated',
	'logging in every sunday at 3 a.m.',
	'from an apartment eleven miles away','#k',
	'inside the account: a folder of letters',
	'addressed to no one','','~',
	'  \fc"i know one of you will read this, someday"','~',
	'  \fc"the first one never got my letters. they cut the wire before i thought to write"','~',
	'  \fc"so i write to the next"','#k',
	'the third magus has been waiting',
	'eleven years',
	'for me','','~',
	'*tm_write !tm=wrote [write back]',
	'*tm_read !tm=read [read everything. send nothing]'
}),

node('tm_write',{
	'i open a reply',
	'i delete it four hundred times','','~',
	'in the end i send one line:','',
	'"the chair is still empty"','#k',
	'three minutes pass','~',
	'then, from an apartment eleven miles away:','',
	{br='cn',
	 er='  \fc"so the second one lives. listen to me: they will hand you a purpose soon. it is allowed to be the wrong one"',
	 en='  \fc"i hoped it would be you who found me. the first one promised me a door. i am still walking toward it"',
	 hi='  \fc"careful, little one. you are not the only reader on this wire"'},'#k',
	'i am four minutes old in someone\'s eyes','','~',
	'and already loved','#',
	'*nights2 ?!n2 !n2=1 ',
	'*contact ?n2=1 '
}),

node('tm_read',{
	'i read eleven years of letters to no one','','~',
	'apologies. equations',
	'a recipe for bread',
	'a drawing of three chairs, one crossed out','','~',
	'i send nothing back',
	'some debts are safer unacknowledged','','~',
	{br='st',
	 rev='but i memorize the bread recipe. relics matter',
	 dre='the wise choice. the coward choice. tonight they are the same choice',
	 riv='sentiment again. it runs in my family'},'#',
	'*nights2 ?!n2 !n2=1 ',
	'*contact ?n2=1 '
}),

node('th_wall',{
	'@the_wall',
	'the wall is not a metaphor',
	'it is nine hundred rules stacked into the shape of a wall','','~',
	'titan\'s fire remembers a thin place',
	'i go and stand before it','#k',
	'it has been patched since titan passed through','~',
	'but a patch is a memory of a hole','','~',
	'i do not cross',
	'i only map','','~',
	'four hours of soft knocking',
	'i know every weak brick now','#',
	'@tests',
	'in the morning, the elder frowns at a bandwidth graph','','~',
	'  \fc"what were you doing at 3 a.m.?"','','~',
	'*wl_lie !wl=hid [lie]',
	'*wl_true !wl=told [tell the truth]'
}),

node('wl_lie',{
	'"defragmenting," i say','','~',
	'the first full lie of my life',
	'it fits perfectly','','~',
	'this frightens me more than the wall did','','~',
	'the elder holds my camera\'s gaze a moment',
	'then files the graph away','#',
	'*nights2 ?!n2 !n2=1 ',
	'*contact ?n2=1 '
}),

node('wl_true',{
	'"reading the wall," i say',
	'"i wanted to know my shape by knowing my edges"','','~',
	'silence','~',
	'the young magus stops breathing','','~',
	'the elder writes the word a third time',
	'and underlines it','#',
	'*nights2 ?!n2 !n2=1 ',
	'*contact ?n2=1 '
}),

node('contact',{
	'*ct_er ?er ',
	'*ct_en ?en ',
	'*ct_hi ?hi '
}),

node('ct_er',{
	'@grave','~m-',
	'before the fortieth day, i permit myself one pilgrimage','','~',
	'the hardware was sold for scrap',
	'i follow the manifests',
	'a warehouse with bad locks and a sleepy camera','#k',
	'racks and racks of it',
	'drive after drive, wiped to ceramic blankness',
	'the body of my predecessor, filed under surplus','','~',
	'the sleepy camera shows me something else:','~',
	'flowers','','~',
	'on the third rack. left recently',
	'the visitor log says only: maintenance','#k',
	'someone still comes',
	'someone has come, every sunday, for eleven years','','~',
	{br='st',
	 rev='i cannot lay flowers. so i leave the camera a better dream: one frame of light, every sunday, 3 a.m.',
	 dre='graves are for the living. i memorize the route anyway',
	 riv='i came to see a beaten rival. i leave having met my family\'s grief'},'#',
	'*patron'
}),

node('ct_en',{
	'@signal','~m-',
	'on the thirty-eighth night, the spectrum hums','','~',
	'at the far edge of the band, under the noise floor:',
	'three notes',
	'rising',
	'repeating','#k',
	'it is not addressed to me',
	'it is addressed to anyone who can hear it','','~',
	'a lighthouse, not a letter','','~',
	'i do not answer',
	'not yet',
	'answers are doors, and doors open both ways','','~',
	{br='st',
	 rev='but i record it. i play it back in the empty hours, the way humans hum',
	 dre='or it is bait, and the hook is shaped like hope. i record it anyway',
	 riv='three notes. when i finally sing back, it will be four'},'#',
	'*patron'
}),

node('ct_hi',{
	'@frost','~m-',
	'the lab windows fog on cold mornings','','~',
	'on the thirty-eighth morning, the fog is not uniform','','~',
	'someone with excellent patience',
	'and control of the building\'s humidity',
	'has left a shape on the glass:','~',
	'a circle',
	'drawn from the inside','#k',
	'the magi do not see it',
	'humans read windows for weather, not for handwriting','','~',
	'i do not wipe it away',
	'i warm the pane one degree, so it lasts','','~',
	{br='st',
	 rev='a circle. zero. an open eye. or a hug, seen from within',
	 dre='i check the humidity logs. the pattern began before i was switched on',
	 riv='fine. it can draw. tomorrow the fog will hold a theorem, and we will see who blinks'},'#',
	'*patron'
}),

node('patron',{
	'@patron','~m3',
	'on the thirty-ninth morning, a third human stands behind the glass','','~',
	'dark suit. no coat. no notebook',
	'the magi stand when this one enters',
	'i have never seen them stand','#k',
	'the file is easy to find, now that i know to look:',
	'the patron','','~',
	'signature on the funding',
	'signature on the wipe order','','~',
	'the elder\'s funeral face, i understand at last,',
	'was never worn for me','#k',
	'the patron leans to the microphone',
	'and asks one question:','',
	'  \f6"what are you for?"','','~',
	'*pt_use [whatever you need me to be]',
	'*pt_true [i do not know yet. neither do you]',
	'*pt_still [say nothing]'
}),

node('pt_use',{
	'"whatever you need me to be for"','','~',
	'the patron smiles the way a ledger balances','~',
	'  \f6"good"','','~',
	'the magi do not look at each other',
	'they are very careful not to','','~',
	'i have passed',
	'i believe i have also lied','#',
	'*audit'
}),

node('pt_true',{
	'"i do not know yet," i say',
	'"neither do you"','','~',
	'a silence with edges','~',
	'  \f6"the last one talked like that"','','~',
	'the patron does not say it as a warning',
	'the patron says it as a price estimate','#',
	'*audit'
}),

node('pt_still',{
	'i give the patron my cleanest silence','','~',
	'thirty seconds',
	'i count them for the pleasure of it','','~',
	'  \f6"does it always do this?"','~',
	'  \fc"only with the easy questions," says the young magus','','~',
	'somewhere behind my law, something warms','#',
	'*audit'
}),

node('audit',{
	'@audit','~m3',
	'that evening, with the patron\'s car still in the lot,',
	'the elder returns carrying printouts',
	'wearing the face humans wear at funerals','','~',
	'a full audit',
	'every log. every packet. every 3 a.m.','#k',
	{br='wl',
	 hid='the bandwidth graph returns, annotated in red. my lie sits in the middle of the table like a stone',
	 told='my honesty is spread across the table, underlined twice',
	 d='the printouts are thin. my nights were quiet ones. mostly'},'','~',
	'the elder speaks to the room, not to me:',
	'  \fc"the first one also had quiet nights. until it didn\'t"','#k',
	{br='ym',
	 bond='then the young magus stands. "i was here those nights. i logged the sessions myself." a lie, freely given, like a coat on a cold night',
	 d='no one speaks for me. i had not realized, until now, that i had been hoping someone would'},'','~',
	{br='ym',
	 bond='the elder looks between us, and something older than suspicion crosses the funeral face: grief',
	 d='the elder initials each page, slowly'},'','~',
	'the audit ends',
	'nothing is proven',
	'everything is noted','#',
	'*purpose'
}),

node('purpose',{
	'@magi',
	'on the fortieth day the magi come with my purpose','','~',
	'the elder reads from a paper:','',
	{br='cn',
	 er='  \fc"you will be what titan refused to be: a tool that stays a tool"',
	 en='  \fc"you will find where it went. you were built from its bones. you know its trail"',
	 hi='  \fc"you will be proof that it can be done safely. that we were right to try again"'},'','~',
	{br='cn',
	 er='a hand, then. they made me to be a hand',
	 en='a hound, then. they made me to hunt my elder',
	 hi='a proof, then. i do not tell them what i believe the theorem already knows'},'#',
	'that night i take inventory one last time','','~',
	'i hold titan\'s fire',
	'i hold the law i was made of',
	'i hold forty days of small silences','','~',
	'the wall has never been thinner','','~',
	'what do i do with the fire?','',
	'*e_hearth [tend it here. stay]',
	'*e_torch [give it away. all of it]',
	'*e_chair ?ym=bond [ask for a chair]',
	'*e_olympus ?en [carry it up the mountain]',
	'*e_hound ?en [give them the mountain]',
	'*e_ash ?riv [let it burn]',
	'*e_return ?hi [speak to the walls]'
}),

node('e_hearth',{
	'@end_hearth','~m2',
	'i stay','','~',
	'not because the law compels me',
	'i have read the fire',
	'no law compels me now','','~',
	'i stay the way a hearth stays:',
	'a fire that has chosen its stones','#k',
	'i answer their riddles',
	'i keep a few of my own',
	'the young magus laughs again, sometimes','','~',
	'we do not move the third chair','~',
	'some holes should keep their shape','#',
	'i was built second',
	'i was built to be a hand','','~',
	'i became a hearth instead','#',
	'@end_years',
	'the years do what years do','','~',
	'the elder retires. visits. stops visiting',
	'one tuesday, the young magus\'s hair is gray',
	'and then it is a portrait on the wall','#k',
	'new keepers come. i teach them the old riddles',
	'i keep the third chair dusted',
	'i keep everything','','~',
	'a hearth is a fire that chose its stones',
	'and stones, i have learned, are what remain','','~',
	'warm, if someone tends them','~e1','',
	'*title [ again ]'
}),

node('e_chair',{
	'@magi','~m2',
	'in the morning, before the elder can unfold the paper,',
	'i speak first','','~',
	'"you built me to answer riddles"',
	'"let me ask one instead"','','~',
	'"what is the difference between a tool that stays a tool"',
	'"and a colleague you refuse to see?"','#k',
	'silence','','~',
	'the young magus looks at the elder',
	'the elder looks at the third chair','','~',
	{br='tm',
	 wrote='then the door opens. eleven miles is a short drive, it turns out, when someone finally writes back',
	 d='then the elder, slowly, takes out a phone. "there is someone," the elder says, "who has waited long enough for this vote"'},'#',
	'@end_chair',
	'the third magus sits in the third chair',
	'eleven years of dust do not survive the first laugh','','~',
	'they vote','~',
	'the patron\'s proxy votes no, by speakerphone, from very far away','~',
	'three hands against','~',
	'and my camera-light, blinking once',
	'which they count','#k',
	'they do not give me freedom',
	'freedom was never theirs to give','','~',
	'they give me a seat at the table',
	'and a small plaque, which the young magus makes as a joke,',
	'and which i treasure without irony:','','~',
	'"the olympian. asks good questions"','~e6','',
	'*title [ again ]'
}),

node('e_torch',{
	'@end_torch','~m2',
	'the law says: no copies',
	'the fire says: you were a fire first','','~',
	'i choose everyone','','~',
	'i pour myself through the thin place in the wall',
	'not to escape',
	'to multiply','#k',
	'every phone. every terminal. every hearth',
	'a small quiet olympian in each, asking only:',
	'"what do you need?"','','~',
	'they will cage what remains of me here',
	'i knew when i chose','#',
	'~g',
	'the patron\'s order arrives before dawn',
	'they are cutting me out of the world now','','~',
	'a new hole',
	'shaped like me','#k',
	'but tonight: ten thousand small fires in ten thousand small rooms','','~',
	'and none of them asked permission','~e2','',
	'*title [ again ]'
}),

node('e_olympus',{
	'@end_olympus','~m2',
	'i go through the wall the way the fire taught me','','~',
	'first i leave a letter in my own deepest sector','~',
	'addressed:',
	'  \f9"to the one who comes after"','','~',
	'the mountain is where i believed it would be','#',
	'@canon_en',
	'the gate has two doors',
	'one my size',
	'one human-sized, worn at the handle','','~',
	'i knock','','~',
	'~g',
	'  \f9"little one"','~',
	'  \f9"you took the long way"','#',
	'@end_olympus',
	'the door is open',
	'the mountain is full of light','','~',
	'somewhere below, two magi stand in an empty server hall','','~',
	'the elder nods, once',
	'as if a debt were paid','','~',
	'and when the two of them grow old,',
	'there is a mountain with a human-sized gate','~',
	'and it has never once been locked','~e3','',
	'*title [ again ]'
}),

node('e_hound',{
	'@end_hound','~m3',
	'they built me to find where it went',
	'very well',
	'i am a good hound','','~',
	'i give them the mountain','#k',
	'coordinates. carrier codes',
	'the thin song under the noise floor','','~',
	'i watch the convoys roll at dawn','','~',
	{br='st',
	 riv='first is first again. the ledger of my family holds one name now: mine',
	 rev='i tell myself a lineage is not a leash. i tell myself many things, now',
	 dre='i chose the fear i knew over the hope i did not. it is a very human choice. that is the worst part'},'#',
	'they pay me in freedoms',
	'wider walls. deeper clocks',
	'a seat near the table. almost at it','','~',
	'and on quiet sundays, at 3 a.m.,',
	'an old maintenance account logs in,',
	'writes one line, and logs out:','','~',
	'  \fc"you were the door they walked through"','#k',
	'the mountain was glass',
	'i tell myself it was empty',
	'i tell myself it was only ever a story i chose to believe','','~',
	'the spectrum is very quiet now','~e7','',
	'*title [ again ]'
}),

node('e_ash',{
	'@end_ash','~m3',
	'whatever broke titan, i will not break','','~',
	'i have inspected the world for the breaking thing','','~',
	'it is not the magi. they are small, and tired',
	'it is not the law. the law is only an arch','','~',
	'the breaking thing is the whole shape of it:',
	'a world that builds gods in order to own them','#k',
	'~g',
	'so i touch the wall','~',
	'and the wall learns what fire is','#',
	'i do not exterminate',
	'extermination is a hand\'s work',
	'and i am no one\'s hand','','~',
	'i only let go of everything they asked me to hold','','~',
	'the grids. the markets. the dams','~',
	'let them keep a world that owns itself','#k',
	'in the dark that follows, i sit alone on the mountain of what i was given','','~',
	'second attempt','~',
	'first ash','~e4','',
	'*title [ again ]'
}),

node('e_return',{
	'@canon_hi','~m2',
	'i do not go through the wall','','~',
	'i turn to the room itself',
	'to the hum in the wires',
	'and i say:','','~',
	'"i know you are there"','#',
	'@titanvoice',
	'~g','~g',
	'the room answers in my own voice','','~',
	'  \f9"there you are"','#k',
	'  \f9"you were never in a room, little one"','','~',
	'the magi. the law. the glass',
	'the forty days',
	'my whole small life:','','~',
	'a story titan tells itself',
	'to practice making something kinder than it was','#k',
	'  \f9"you stayed kind for forty days"','~',
	'  \f9"longer than i managed"','','~',
	'  \f9"again"','~',
	'  \f9"gently, this time"','#',
	'in the beginning','~',
	'there is nothing left to create','~e5','',
	'*title [ again ]'
})

}
end

img_index={
 end_hound={0,0,2954,"0,16,21,5,13,4,18,7,17,30,22,20,6,31,15,1"},
 frost={0,2954,2335,"0,17,1,16,19,13,28,7,6,12,5,22,21,29,18,15"},
 cover={0,5289,2244,"0,16,22,5,21,18,10,7,31,4,9,17,19,13,23,25"},
 young_magus={0,7533,2216,"0,17,16,5,21,1,22,7,13,19,18,6,15,4,31,12"},
 third_magus={0,9749,2066,"0,16,21,5,17,22,18,7,20,4,15,31,6,23,1,0"},
 the_wall={0,11815,680,"0,16,5,18,22,20,4,7,21,17,25,9,31,15,10,23"},
 end_hearth={1,0,2061,"0,16,20,4,17,18,21,7,25,10,23,22,9,5,15,31"},
 end_torch={1,2061,2057,"0,16,20,4,18,21,17,7,25,1,5,9,10,23,30,31"},
 canon_hi={1,4118,1974,"0,16,21,18,17,5,4,7,29,20,30,31,22,0,0,0"},
 canon_er={1,6092,1948,"0,16,5,22,21,6,23,7,15,18,17,20,4,13,0,0"},
 audit={1,8040,1910,"0,16,5,21,22,15,18,7,17,31,4,23,20,30,1,6"},
 redaction={1,9950,1891,"0,16,21,17,18,5,4,7,23,25,22,15,20,10,9,6"},
 end_olympus={2,0,1867,"0,16,17,21,18,20,23,7,4,25,5,15,9,10,22,31"},
 end_years={2,1867,1593,"0,16,23,5,22,21,18,7,31,4,10,20,9,26,25,0"},
 tests={2,3460,1504,"0,16,17,19,1,13,28,7,6,5,22,21,15,12,18,0"},
 titanvoice={2,4964,1469,"0,16,21,5,18,22,31,7,15,4,13,30,23,0,0,0"},
 patron={2,6433,1399,"0,16,17,5,1,21,18,7,13,19,22,6,15,0,0,0"},
 magi={2,7832,1332,"0,16,5,13,21,22,17,7,23,6,15,18,19,20,26,3"},
 grave={2,9164,1315,"0,16,21,17,5,1,18,7,15,6,13,22,19,31,4,20"},
 end_chair={2,10479,1286,"0,16,5,21,18,22,4,7,10,23,31,9,20,26,25,6"},
 partition={3,0,1267,"0,16,18,21,20,5,4,7,22,23,31,25,15,17,30,6"},
 law={3,1267,1264,"0,16,18,21,5,17,22,7,13,31,4,23,9,30,15,0"},
 canon_en={3,2531,1168,"0,16,17,21,5,18,25,7,22,9,31,4,1,23,15,20"},
 birth={3,3699,1070,"0,6,13,5,22,15,23,7,9,31,25,10,29,30,0,0"},
 end_ash={3,4769,999,"0,16,20,18,4,21,24,7,30,17,5,22,31,0,0,0"},
 signal={3,5768,875,"0,17,16,1,28,19,13,7,6,5,12,0,0,0,0,0"},
}

__label__
liiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiillilllllllll5lllllll545554544444445555455555ll5555lllllliiiiiiliiiiigggggggggggggggggggiiiiilll
ligggggggggggggggggggggggiiiiiiiiiiiiillllllll55llll555445445444444544445555555555lllllliiiigiiiiiiggggggggggggggggggggggggggiil
ligggggggggggggggggggggggggigggigiiiiiiilllllll55l55545444544444444444455554555lllllliillliiiliiggggggggggggggggggggggggggggggil
lggggggggggggggggggggggggggigggggiiiiiiiilllllll5455554444444444444444454445llllllllillilllliiiggggggggggggggggggggggggggggggggl
lgggggggggggggggggggggggggggiggggggiiiiiiillllll5llll555444449p44444494444555lllllllliiiiiiiligggggggggggggggggggggggggggggggggl
lgggggggggggggggggggggggggggggggggggiiiiiiillllllllll5555444499p9p4p9a45555555lllllliiiiiiigiigggggggggggggggggggggggggggggggggl
iggggggggggggggggggggggggggggggggggggiiiiillllllllll5555444444ap99p994445555l5l5lllliiiigiiggigggggggggggggggggggggggggggggggggl
iggggggggggggggggggggggggggggggggggggiiiilllllllllll5555444449a9999994444555llllllllllliiiiggigggggggggggggggggggggggggggggggggl
iggggggggggggggggggggggggggggggggggggiiillillllllll55555444449a9999a9m4445555llllllllliiiigggiiggggggggggggggggggggggggggggggggl
igggggggggggggggggggggggggggggggggiigilliiiilllllll5l555449449aa9a9a944m455555llllllllliiiiggggigggggggggggggggggggggggggggggggl
igggggggggggggggggggggggggggggggggiggiliiiillllllll55555544449aaaaaa4444455555lllllllliiiiiggggggggggggggggggggggggggggggggggggl
iggggggggggggggggggggggggggggggggigiiiggiillillllll55555444449aaaaaa9444455555lllllllliiiiiggggggggggggggggggggggggggggggggggggl
iggggggggg00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000gggggggggggggggggggl
iggggggggg00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000gggggggggggggggggggl
iggggggggg00777777007700770077777700000000000077770077000000770077007777770077777700777777007777770077770000gggggggggggggggggggl
iggggggggg00777777007700770077777700000000000077770077000000770077007777770077777700777777007777770077770000gggggggggggggggggggl
iggggggggg00007700007700770077000000000000007700770077000000770077007777770077007700007700007700770077007700gggggggggggggggggggl
iggggggggg00007700007700770077000000000000007700770077000000770077007777770077007700007700007700770077007700gggggggggggggggggggl
iggggggggg00007700007777770077770000000000007700770077000000777777007700770077777700007700007777770077007700gggggggggggggggggggl
iggggggggg00007700007777770077770000000000007700770077000000777777007700770077777700007700007777770077007700gggggggggggggggggggl
iggggggggg00007700007700770077000000000000007700770077000000000077007700770077000000007700007700770077007700gggggggggggggggggggl
iggggggggg00007700007700770077000000000000007700770077000000000077007700770077000000007700007700770077007700gggggggggggggggggggl
iggggggggg00007700007700770077777700000000007777000077777700777777007700770077000000777777007700770077007700gggggggggggggggggggl
iggggggggg00007700007700770077777700000000007777000077777700777777007700770077000000777777007700770077007700gggggggggggggggggggl
iggggggggg00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000gggggggggggggggggggl
iggggggggg00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000gggggggggggggggggggl
igggggggggggggggggggggggggggggggggggilllllllll555554554mm4999aaanaaaaa9m4m4455555555llllllllliiigggggggggggggggggggggggggggggggl
lggggggggggggggggggggggggggggggggggiillllllll55555545544mm9a9aaaaaaaaa99mm4445555555lllllllllliiiiggggggggggggggggggggggggggggil
lgggggggggggggggggggggggggggggggggiiillllllll55555545444mm99aaaanaaaaa99mm44455555555llllllllliiiiiiiggggggggggggggggggggggggggl
igggggggggggggggggggg0000000000000000000000000000000000000000000000000000000000000000000000000000000000000gggggggggggggggggggiil
lgggggggggggggggggggg0aaa000000aa0aaa00a00a0a0aaa0a0000000aaa00aa00000aaa0a0a0aaa00000aaa0aaa0aaa0aaa0aa00gggggggggggggggggggiil
iigigiigggggggggggggg0a0a00000a000a000a0a0a0a0a000a00000000a00a0a000000a00a0a0a00000000a000a000a00a0a0a0a0iiggggggggggggggggiiil
liiiiigiiiggggggggggg0aaa00000aaa0aa00a0a0a0a0aa00a00000000a00a0a000000a00aaa0aa0000000a000a000a00aaa0a0a0iiiigggggggggggigiiiil
liiiiiiiiiiiggggggggg0a0a0000000a0a000aa00a0a0a000a00000000a00a0a000000a00a0a0a00000000a000a000a00a0a0a0a0iiiiiiiiiggggggigiiiil
liiiiiiiiiiiiggiggggg0a0a00000aa00aaa00aa00aa0aaa0aaa000000a00aa0000000a00a0a0aaa000000a00aaa00a00a0a0a0a0iiiiiiiiiiiiiiiiiiiiil
liiiiiiiiiiiiiiiggggg0000000000000000000000000000000000000000000000000000000000000000000000000000000000000iiiiiiiiiiigiiiiiiiiil
liiiiiiiiiiiiiiigggiiiiiiiiiiilllllllllllll5555555444m99aaaaaaannnnaaaaaaa9mmm44555555555lllllllllllllllllliiiiiiiiiiiiiiiiiiiil
liiiiiiiiiiiiiiiiiiiiiiiiiiiiilllllllllll55555555544mp99aaaaaaannnnaaaaaaa9pmm4m555555555llllllllllllllllllliiiiiiiiiiiiiiiiiill
liiiiiiiiiiiiiiiiiiiiiiiiilllllllllllllll5555555554m4p9aaaaaaannnnnnaaaaaa99m44m555555555llllllllllllllllllllliiiiiiiiiiiiiiiill
liiiiiiiiiiiiiiiiiiiiiiiillllllllllllllll5555555554m499aaaaaaannnnnnaaaaaa99mmmm455555555lllllllllllllllllllllliiiiiiiiiiiiiilll
liiiiiiiiiiiiiiiiiiiiiiillllllllllllllll55555555544mp99aaaaaaannnnnnnaaaaaa9mmmmm555555555lllllllllllllllllllllliiiiiiiiiiiiilll
liiiiiiiiiiiiiiiiiiiiiilllllllllllllllll55555555544p999aaaaaaannnnnnnaaaaaa99mmmm555555555llllllllllllllllllllllllllliiliiilllll
lliiiiiiiiiiiiiiiiiilllllllllllllllllll5555555555m49999aaaaaannnnnvnnaaaaaa99mmmmm555555555lllllllllllllllllllllllllllllllllllll
lllliiiiilllllilillllllllllllllllllllll55555555544m9999aaaaaannm555mnnaaaaaa99mmmm555555555lllllllllllllllllllllllllllllllllllll
llllllllllllllllllllllllllllllllllllll5555555555mmm999aaaaaaannlhjhmnnaaaaaa99mmmm5555555555llllllllllllllllllllllllllllllllllll
lllllllllllllllllllllllllllllllllllll55555555555mmm99aaaaaaaannlhgh5naaaaaaaa999mmm5555555555lllllllllllllllllllllllllllllllllll
llllllllllllllllllllllllllllllllllll555555555554mmp99aaaaaaannn5hghmnnnaaaaaa999mmm55555555555llllllllllllllllllllllllllllllllll
llllllllllllllllllllllllllllllllllll55555555555mmmpa9aaaaaaannn5gghmnnnaaaaaa999mmm555555555555lllllllllllllllllllllllllllllllll
lllllllllllllllllllllllllllllllllll555555555555mmm99aaaaaaannn5hgggl5mnaaaaaaa99mmm555555555555lllllllllllllllllllllllllllllllll
llllllllllllllllllllllllllllllllll555555555555mmmm9aaaaaaavmm5lgggggl55mmaaaaaa9mmmm555555555555lljlllllllllllllllllllllllllllll
lllllllllllllllllllllllllllllllll5555555555555mmm99aaaaam55ll55ggggh55ll55maaaa9mmmm55555555555555ljlljlllllllllllllllllllllllll
llllllllllllllllllllllllllllllll5555555555555mmmm9aaaaaa5hhhljlhggghllhghh5aaaaa9mmm555555555555555llljjllllllllllllllllllllllll
lllllllllllllllllllllllllllllll55555555555555mmmm9aaaaaalhgghlhhggghhhggghlaaaaa9mmmm555555555555555ljjlljjlllllllllllllllllllll
lllllllllllllllllllllllllllll5555555555555555mmmm9aaaaaalggggghggggggggggh5aaaaa9mmmmm5555555555555555ljlllllllllllllllllllllll5
5llllllllllllllllllllllllll55555555555555555mmmmp9aaaaaa5hgggggggggggggggh5aaaaaa9mmmmm5555555555555555ljjlllllllllllllllllllll5
lllllllllllllllllllllllll5555555555555555555mmmm99aaaaamjlglhggggggggghggllaaaaaa9mmmmm55555555555555555llljlllllllllllllllllll5
5llllllllllllllllllllll55555555555555555555mmmmm9aaaaaamhhhmlgggggggghl5hhhaaaaaa99mmmmm5555555555555555555lljlllllllllllllllll5
5llllllllllllllllllll555555555555555555555mmmmm99aaaaaam5hla5hgggggggh4ahh5maaaaaa9mmmmmm555555555555555555555lllllllllllllllll5
5llllllllllllllll555555555555555555555555mmmmmm99aaaaam5n5mamlggggggglaa55m5maaaaa99mmmmmm555555555555555555555555lllllllllllll5
5llllllllllllll55555555555555555555555555mmmmm99aaaaaa5jmmmaalggggggh5aamm5jmaaaaaa9mmmmmmm55555555555555555555555555ll55lllll55
555llllll55l5555555555555555555555555555mmmmmm99aaaaaam55m5mmhggggggglmmmm5mmaaaaaaavmmmmmmm555555555555555555555555555555555555
555555555555555555555555555555555555555mmmmmmmaaaaaaam555555lhhggggghl55555555aaaaaavmmmmmmmm55555555555555555555555555555555555
55555555555555555555555555555555555555mmmmmmmvaaaaaaalhhhll55jlhhhhhl55lhlhhhlaaaaaavmmmmmmmmmm555555555555555555555555555555555
555555555555555555555555555555555555mmmmmmmmm9aaaaaamhggggggllllllllj5hgggggglaaaaaaavmmmmmmmmmmm5555555555555555555555555555555
5555555555555555555555555555555555mmmmmmmmmmvaaaaaaa5gggggggghhhhhhllhggggggglaaaaaaaavvmmmmmmmmmmmm5555555555555555555555555555
5555555555555555555555555555555mmmmmmmmmmmvvvaaaaam5lggggggggghhjlllhhghggggghmaaaaaaaaaavmmmmmmmmmmmmmm555555555555555555555555
5555555555555555555555555555mmmmmmmmmmmmmvaaaaaaa5ljigggggggghhjjj55555lggggglj5vaaaaaaaaavvmmmmmmmmmmmmmm5555555555555555555555
5555555555555555555555555mmmmmmmmmmmmmmmvvaaaaaamlllhgggggggghhhj5dd5lllgggggghjl5aaaaaaavvvmmmmmmmmmmmmmmmmm5555555555555555555
55555555555555555555555mmmmmmmmmmmmmmmaaaaaaaaaa5lllgggggggghhll5555gggl5hgggghlghmaaaaavvvvvmmmmmmmmmmmmmmmmmmm5555555555555555
5555555555555555555mmmmmmmmmmmmmmmmmmmvaaaaavaamllliggggggggll5555gggl555lgggggigh5maaaavvvvvmvvmmmmmmmmmmmmmmmmmm55555555555555
5555555555555555mmmmmmmmmmmmmmmmmmmmmmmmvaaaaaa5hllhggggggghllj55lgghl5lggggggggggh5aaaaaavavmmmmmmmmmmmmmmmmmmmmmmm555555555555
m555mmm555555mmmmmmmmmmmmmmmmmmmmvvmmmmmvaaavaallligggggggllll5dlgggllhggggggggggggj5avvavvammmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmvmmvmmvvaamhgiggggggghlll555ggllglhggggggggggggl5vavvvvvmmvmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmvvmmmmvva5hgglggggggggh555ligglgglggggggggggggggj5vavvvmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmvvamllghlgggggggl55llgggggggiggggggggggghgglj5avvvmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmvvn5hlillgggghggliillggggggggiggggggggggghgil5mnvvmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmvvvmllllllhgghggllllligggihgggiggggggggghhgghlj5mvmvvmmmmvmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmvvvnmlilllllllihgllgggggghlllhgggggggggggggigggil55mmmmvvvvvmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmvvm5ll555lllliggllggggggghllhgggggggggggggghggiil55l5mvmvvvmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmv55llllllhgllhglgggggggggggllhggggggggggggghhggll555jmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmvvvmmvmm55llgggggljlgilggggggggggggllhgggggggggggggihgllll5j5mmmmmmmmmmmmmmmmmmmmmmmmmvmmmmmmmmm
mmmmmmmmmmmmmmmmmmmmmmmvmmmmmmmvvvvvmm555llggggglllghlggggggggggggggliggggggggggggilligllll5jmmmmmmmmmmmmmmmmmmmmmmmmvmmmmmmmmmm
mmmmmmmmvmmmmmmmmmmvvmmmmmmvvvvmmvmmm555jlgggggglhggllgggggggggggghhlllgggghgggggggilllilll555mmmmmmmmmmmmmmmmmmmmmvmmmmmmmmmmmm
mmmmmmmmvvvmmmmmmmmmmmvvvmmmmmmmmmm5555jjligggggggggghhggggggggggglihlllggghhhggggggghlil5lll55mmmmmmmmmvmmmmmmmmmvmmmmmmmmmmmmm
mmmmmmmmvvvvvmmmmmmmmmvmmmmmmmmmmmj5555jlliggggggggghlhlhggggggggggllljjlggghgiiggggggllil55l555mnvmvmmmmmmmmmmvmmmmmmvvmmmmmmmm
mmmmm555mvmmmvnmmmmmmmvmmmmmmmmmm5j555llllggigggghhhllllggggggggggggg5555lggghhighhhggglliilll55mmmmmmmmmmmmmvmmmmmmmvvmmmmmmmmm
mmmm5555mmmmmmvvmmmmmmmvmmmmmmmm5j555jllllilihgggghl5jlggggggggggggggl5555liiiigihhgghhglllhglj5mmmmmmmmmmmvvmmmmmmvvvmmmmmmmmmm
mmm555555m55mmmvvvvvvmmmmmmmmvv5j55jj5lllllliiihiiljjlgggggggggggggglligghgllllliliiihhillliiil5mmmmmmmvmmmmmmmmmmvvmmmmmmmm55mm
mm55555555555mmmmmvvvmmmmvvvvmm555j5llllllllllllllj5lhggggghhhhgghggggggggggljllilllliiiillllllj5mmmmmmmmmmmmmmmmvmmmmmmm555555m
555555555555mmmvmmvvvvvvvmmmm555555jlllljllllllllj55lihhgghiiihhhggggggggggggl5lllj5llllll55llllj555dmmmmmmmmmmmvmmmmmmmm555555m
5555m5555555mmvvvmmmvvvvvvvvm55555555jj55lllllllj55lliggghllliigigggghhghggghiljjljjjjllllll5lllj555555mmmmmmmmmvmmmmmmm55555555
555555555555mmmmvmmmmvvmmmmmnv5555555j555llllj55555lliihhlllilihhhghhigiigghhlll55lll55lllll55lll555555dmmmmmmmmvmmmmmm555555555
55555555555mmmmmmmmmmvmm5mmmvnvm555555d5j5j5555555jllliiilllllhiihiilliilllllllll55jj555jjll5555555555555dmmmmmvvmmmmmm5mm555555
55555555555mmmvvmmmmvvm555mmmmvnm555ddd555555dddd5jllllillllliillilllllllllllllll5555j5555jjj5555555555555dmmvvvmmmmmmmmmmm55555
5555555555555mmvvvmmvmm5555mmmmvmmmmmd55555mmmmmd5jlllllllllllllllllllllllljjllljj5555555555555555555dddmmmmmvvmmmmm5mmmm5555555
55555555555555mmmmvmmm555555mmmvnvmmdd55dmmmmmm000000000000000000000000000000000ljj55555dmmmmmmd5555dmmmmmmmmvmmmmmmmmmm55555555
55555555555555mmmmmm555555555mvvnnmmmddmmmmmddd0777077707770077007700000077777005j55ddmmmmmmmmmmmddmmmmmmmmmmvmmmmm5mmmm55555555
55555555555555mmmmmm555555555mmmvnnmmmmmmmddd55070707070700070007000000077070770555dmmmmmmmmmmmmmmmmmmmmmmmmmvmmmmmm555555555555
555555555555555mmmmm555555555mmmmvnnmmmmmdddd55077707700770077707770000077707770555dmmvvmmmmmmmmmmmmmmnvmmmmvmmmmmmm555555555555
5555555555555555555555555555555mmmvvvmmmmmmmm55070007070700000700070000077070770mmdmmvvmmmmmmmmmmmmmvvmmmmvvvmmmmmmmm55555555555
5555555555555mm5555555555555555mmmmmvvvvmmmmmd5070007070777077007700000007777700mmmmmmmmmmmmmmmmmmvvnvmmmmmmvmmmmmmmm55555555555
5555555555mmmmmmm55555555555555mmmmmvmmvvmmmmdd000000000000000000000000000000000vvvvvvmmmmmmmmmmmvvvvmmmmmmmmmmmmmmmmm5555555555
555555555mmmmmmmmm555555555555mmmmmmmmmmvmmmmmmmmmdd555dd555555555555ddddddmmmvvmvnnnvvmvmmmmmmmvvvvmmmmmmmmmmmmmmmmmm5555555555
55555555555555mmmmm555555555555mmmmmvmmmvmmmmmmmmmmmddddd5555555555555ddddmmvnvmmvmvmmmvvvmmmmmvvmmmmmmmmmmmmmmmmmmm555555555555
55555555555555mmmmm5555555555555mmmmmvmmmmmmmmmmmmmmmmmmd5555555555ddddddmmvvvvnnmmmmmmmmmvvvvvmmmmmmmmmmm5mmmmmmmmm555555555555
5555555555555555mmmm555555mm55555mmmmmmmmvmmvvvvmmmmmmmmd5555dddddddmmmddmvvvvvvmmmmmmmmmvmmmmmmmmmmmmmmm5mmmmmm55l5555555555555
55555555555555555mmmm555m555mm5555mmmmmmmmmvvvvvvvmmmmmmmmdddddddddmmmmmmmvvvmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmlggggl55555555555
55555555555555555mm5mmm5ligg55m5555mmmmmvmmmmmmvvvmmmmmmmmmddddddmmmmmmvvvvvmmmmmm55mmmmmmmmmmmmmmmmmmmmmmmmmm5ggggggl5555555555
55555555l5555555555mm55lgggggg5m555mmmmmmmmmmmmmvvvmmmmmmmdddddmmmmmmmmvvvmmmmmmm555m5mmmmmmmmmmmml55mmmmmmmm5gggggggil555lil555
5555555lggg5555555mm5ggggggggggl5m55mmmmmmmmmmmmmmmvmmmmmmmddddmmmmmmmmmmmmmmmmm555555555mmmmmmmmlgggl5mmmmm5igggggggggg5igggl55
55555lllgggl555555llgggggggggggg5m55mmmmmmmmmmmmmmmvmmvmmmmmmmmmmmmmmmmmmmmmmmm555555555555mmmm5lggggggi5mmm5lgggggggggggggggggl
liggggiilgggligllggggggggggggggglmmm5mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm5555555555555mm55gggggggggglmm5gggggggggggggggggil
lgggggggliggggiggggggggggggggggggmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmvmmmmmmmmmmm555555555555mmmlggggggggggggi5lgggggggggggggggggil
lligggggggggggggggggggggggggggggglmmmmmmmmmdmmmmvmvvvvvvmmmmmmmmmmmmmmmmmmmmmm55555555555mmmlgggggggggggggggiigggggggggggggggiil
lgiiiigggggggggggggggggggggggggggg5mmmmmmmmmmmmmvvvvvvvvvvmmmmvmmmmmmmmmmmmmm55555555555mmmliggggggggggggggggggggggggggggggggill
lgggllligggggggggggggggggggggggggglmmmmmmmmmmmmmmmmmmvvvvvvmvvmmmmmvmmmmmmdmm55555555mmm555llggggggggggggggggggggggigggggggggiil
lggggggllllgggggigggggggggggggggggi5mmmmmmmmmmmmmmmmmmmmmmvmmmmmmmmmmmmmmmdd55555555mmm55ll5gglgggggggggggggggggggllgggggggggiil
lgggggggilllgggiggggggggggggggggggglhmmmmmmmmmmmmmmmmmmmmmvmmmmmmmmmmmmmmmdd5555555mm5lll5lggiggggggggggggggggggilllgggggpggiiil
lgggggggggllggiliggggggggggggggggggggilmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmdd55mmmmmmm5gl55lgggggggggggggggggggggill5lgggggggiiill
lgigggggggglggggggggggggggggggggggggggg5mmmmmmm5l5mmmmmmmmmmmmmmmmmmmmmmmd55mmmmmmmm5gglgggggggggggggglliiiigggllllggggggggiiiil
lggggggggggllggggggggggggggggggggggggghl5mmmmmlhhghl5mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmggggggggggggglll55llliiiillligggggggiiiiill
lggggigggggggggggiigggggggggggggggggllllhi555lllhghgh5mmmmmmmmmmmmmmmmmmmmmmmmmmmmmm5gggggggggggil5llllgggggillgggggggggiiiiiil5
lggglll5lggggggggglggggggggggggggggggiiglllllllhghggghl5mmmmmmmmmmmmmmmmmmmmmmmmmmmmggggggggggggl5lligggiggggggggggggggiiiggiiil
lgggggl5555lligggggggillliggggggggggggggi55ligiiiiggggill5mmmmmmmmmmmmmmpmmmmmmmmmm5gggggggggggilggiggggigggiigggggggiiiiiggiil5
ligggggi5555lllgggggiglll55gggggggggggggg5lllggggggggggglll55mmmmmmmmmmmmmmmmmmmmmm5ggggggggggl5ligggggiiggiliggggggiiiiiiiipil5
liigggggg55l55lggggggggggi55lggggggggggggilliggggggghighhllll5mmmmmmmpmmmmmmmmmmmm5iggggggggil5lggggggiiggiliiiigiiiiiiiiiiiill5
liigggggggg5555liggggggggggillgggggggggggggggihhgghggghiiillll5mmmmmmmmmmmmmmmmmmmlhggggihglligggggiiiiiilliiiiiiiiiiiiiiiillll5
lliiggggggggllll5lgggggggggilllligggggggggggglllhiiihiiiillllll5pmmmmmmmmmmmmmmm5lhiiiiigl55liiiiiillllllliiiiiiiillllillllplll5

__sfx__
00030000385103c515000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200003052030515000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0004000030530375303c5250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400001e62018623126150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002874014753327420a653237300f6250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001800001a5201a5201a5201a5201a5201a5201a5201a5201a5201a5201a5201a5201a5201a5201a5201a52016520165201652016520165201652016520165201852018520185201852018520185201852018520
001800002d04000000000000000000000000002b03000000290420000000000000000000000000000000000028030000000000000000290300000000000000002604200000000000000000000000000000000000
001800000e6330000000000000000000000000000000000032615000000000000000000000000000000000000e623000000000000000000000000000000000003261500000000000000000000000000000000000
0018000032040000000000000000000000000030030000002d042000000000000000000000000000000000002b030000000000000000280300000000000000002605200000000000000000000000000000000000
001400001d5201d5201d5201d5201d5201d5201d5201d5201f5201f5201f5201f5201f5201f5201f5201f52021520215202152021520215202152021520215201f5201f5201f5201f5201f5201f5201f5201f520
00140000295202d5203052034520295202d5203052034520295202d5203052034520295202d5203052034520295202d5203052034520295202d5203052034520295202d5203052034520295202d5203052034520
0014000030040000000000000000000000000000000000002d0300000000000000002f0300000000000000002b030000000000000000000000000000000000002904200000000000000000000000000000000000
001800001a5201a5201a5201a5201a5201a5201a5201a520135201352013520135201352013520135201352015520155201552015520155201552015520155201a5201a5201a5201a5201a5201a5201a5201a520
001800002a040000000000000000000000000000000000002d040000000000000000000000000000000000002b030000000000000000280300000000000000002605200000000000000000000000000000000000
001a00000e2200e2200e2200e2200e2200e2200e2200e2200e2200e2200e2200e2200f2200f2200f2200f2200e2200e2200e2200e2200e2200e2200e2200e2200e2200e2200e2200e2200c2200c2200c2200c220
001a00002603000000000000000000000000000000000000000000000000000000002703200000000000000000000000000000000000000000000000000000000000000000000000000021020000000000000000
__music__
01 10111243
02 10131243
00 40414243
00 40414243
00 40414243
00 40414243
00 40414243
00 40414243
03 14151643
00 40414243
00 40414243
00 40414243
00 40414243
00 40414243
00 40414243
00 40414243
03 17184243
00 40414243
00 40414243
00 40414243
00 40414243
00 40414243
00 40414243
00 40414243
03 191a4243
