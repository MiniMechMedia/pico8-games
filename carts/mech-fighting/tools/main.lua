-- one must fall: pico
-- a demake of one must fall 2097

--==== data ====
gy=101
-- pose ids: 1 idle 2 walk1 3 walk2 4 punch 5 kick 6 jump 7 crouch
--           8 lowp 9 hit 10 block 11 down 12 win 13 cast

function mkmech(s,plt,alt)
 local v=split(s)
 return {nm=v[1],tag=v[2],qt=v[3],spd=v[4],hp=v[5],dmul=v[6],
  jv=v[7],cd=v[8],ac=v[9],plt=split(plt),alt=split(alt)}
end
md={
 mkmech("jaguar,agile assault har,you're scrap metal!,1.4,95,1,-5.2,70,9",
  "6,9,5,4,8,10,2,4,12,10,7,15","6,4,5,2,8,8,2,2,12,10,7,9"),
 mkmech("electra,ranged shock har,how shocking!,1.6,88,0.85,-5.6,55,12",
  "8,12,2,1,12,7,6,6,5,5,7,7","8,11,2,3,12,11,6,6,5,5,7,7"),
 mkmech("pyros,heavy burner har,you got burned.,1.1,110,1.2,-4.9,80,8",
  "6,5,5,2,8,8,2,2,12,10,7,6","6,13,5,1,8,9,2,4,12,9,7,6"),
}
function mkatk(s)
 local v=split(s)
 return {su=v[1],ae=v[2],du=v[3],x=v[4],y=v[5],w=v[6],h=v[7],
  dm=v[8],kx=v[9],hs=v[10],pz=v[11],sx=v[12]}
end
ak={
 pn=mkatk("4,9,15,18,30,12,8,6,1.4,14,4,3"),
 kk=mkatk("7,13,23,24,26,14,8,10,2.2,19,5,4"),
 lp=mkatk("4,9,16,18,10,12,8,5,1,13,8,3"),
 ja=mkatk("4,17,30,20,24,14,10,9,1.8,17,5,4"),
}

parts={}
bolts={}
shk=0 hstop=0 flash=0
msg="" msgt=0 mbig=false

--==== helpers ====
function say(s,d,b)
 msg=s msgt=d or 60 mbig=b~=false
end
function oprint(s,x,y,c,o)
 for d in all{{-1,0},{1,0},{0,-1},{0,1}} do
  print(s,x+d[1],y+d[2],o or 1)
 end
 print(s,x,y,c)
end
function bigc(s,y,c,o)
 oprint("\^w\^t"..s,64-#s*4,y,c,o)
end
function setplt(f)
 local p=f.clash and f.md.alt or f.md.plt
 for i=1,#p,2 do pal(p[i],p[i+1]) end
end
function spark(x,y,n,c1,c2)
 for i=1,n do
  add(parts,{x=x,y=y,vx=rnd(4)-2,vy=rnd(4)-2,l=6+rnd(6),c=rnd(1)<.5 and c1 or c2,r=1})
 end
end
function dust(x,y,n)
 for i=1,n do
  add(parts,{x=x+rnd(10)-5,y=y,vx=rnd(1)-.5,vy=-rnd(.8),l=12+rnd(8),c=5,r=1+rnd(1)})
 end
end
function scrap(f)
 local a=f.md.ac
 for i=1,20 do
  add(parts,{x=f.x,y=f.y-24+rnd(20),vx=rnd(5)-2.5,vy=-1-rnd(3.5),
   l=40+rnd(30),c=({5,6,7,a})[1+flr(rnd(4))],r=1+rnd(2),g=.22,bn=true,sq=rnd(1)<.6})
 end
 for i=1,8 do
  add(parts,{x=f.x,y=f.y-28,vx=rnd(2)-1,vy=-rnd(1.5),l=25+rnd(20),c=rnd(1)<.5 and 5 or 13,r=3+rnd(3),sm=true})
 end
end
function pupd()
 foreach(parts,function(p)
  p.x+=p.vx p.y+=p.vy p.l-=1
  if p.g then p.vy+=p.g end
  if p.bn and p.y>gy+2 then p.y=gy+2 p.vy*=-.45 p.vx*=.7 end
  if p.sm then p.r+=.08 end
  if p.l<=0 then del(parts,p) end
 end)
end
function pdraw()
 foreach(parts,function(p)
  if p.sq then
   rectfill(p.x,p.y,p.x+p.r,p.y+p.r,p.c)
  elseif p.sm then
   circ(p.x,p.y,p.r,p.c)
  else
   circfill(p.x,p.y,p.r*(p.l<5 and .5 or 1),p.c)
  end
 end)
end

--==== fighters ====
function newf(mi,pl,ai)
 local m=md[mi]
 return {md=m,mi=mi,pl=pl,ai=ai,x=0,y=gy,vx=0,vy=0,fc=1,
  hp=m.hp,dhp=m.hp,st="id",t=0,cool=0,wins=0,inv=0,blk=0,mx=0,cmb=0}
end
function airb(f) return f.y<gy-.5 end
function fin(f,e)
 if f.ai then return aithink(f,e) end
 local b=f.pl
 return {mx=(btn(1,b) and 1 or 0)-(btn(0,b) and 1 or 0),
  u=btnp(2,b),d=btn(3,b),p=btnp(4,b),k=btnp(5,b)}
end

function tryatk(f,a)
 f.st="at" f.t=0 f.ak=a f.hf=false
end
function startsp(f)
 f.st="sp" f.t=0 f.hf=false f.cool=f.md.cd
 sfx(8+f.mi)
end

function aithink(f,e)
 local i={mx=f.aim or 0,u=false,d=false,p=false,k=false}
 f.ait=(f.ait or 0)-1
 if f.ait>0 then
  if f.aib then i.mx=e.x>f.x and -1 or 1 end
  return i
 end
 f.ait=8-dif f.aib=false
 local d=abs(e.x-f.x)
 local twd=e.x>f.x and 1 or -1
 local r=rnd(1)
 -- block reaction
 if (e.st=="at" or e.st=="sp") and d<44 and rnd(1)<.17*dif then
  f.aib=true i.mx=-twd f.aim=-twd return i
 end
 if d>52 then
  if f.mi==2 and f.cool<=0 and r<.35 then i.d=true i.k=true
  elseif r<.75 then i.mx=twd
  elseif r<.85 then i.mx=twd i.u=true
  else i.mx=0 end
 elseif d>26 then
  if f.mi==1 and f.cool<=0 and r<.3 then i.d=true i.k=true
  elseif r<.6 then i.mx=twd
  elseif r<.7 then i.mx=twd i.u=true
  elseif r<.8 then i.mx=-twd
  else i.mx=0 end
 else
  if f.mi==3 and f.cool<=0 and (airb(e) or r<.12) then i.d=true i.k=true
  elseif r<.34 then i.p=true
  elseif r<.55 then i.k=true
  elseif r<.68 then i.d=true i.p=true
  elseif r<.8 then i.mx=-twd
  else i.mx=twd end
 end
 f.aim=i.mx
 return i
end

function fup(f,e,ctrl)
 f.t+=1
 f.cool=max(0,f.cool-1)
 f.inv=max(0,f.inv-1)
 f.blk=max(0,f.blk-1)
 f.dhp+=(f.hp-f.dhp)*.1
 local i={mx=0,u=false,d=false,p=false,k=false}
 if ctrl and f.st!="hs" and f.st!="kd" and f.st!="ko" and f.st!="lg" then
  i=fin(f,e)
 end
 f.mx=i.mx
 local st=f.st
 if st=="id" or st=="wk" then
  f.fc=e.x>f.x and 1 or -1
  if i.p then tryatk(f,ak.pn) sfx(2)
  elseif i.k and not i.d then tryatk(f,ak.kk) sfx(2)
  elseif i.d and i.k and f.cool<=0 then startsp(f)
  elseif i.d and i.p then tryatk(f,ak.lp) sfx(2)
  elseif i.u then f.vy=f.md.jv f.y-=1 f.st="jp" f.t=0 sfx(6)
  elseif i.d then f.st="cr" f.t=0
  elseif i.mx!=0 then
   f.st="wk" f.vx=i.mx*f.md.spd
  else
   f.st="id" f.vx=0
  end
  if st=="wk" and f.st=="wk" and f.t%9==0 then dust(f.x-f.fc*8,gy+2,1) end
 elseif st=="cr" then
  f.fc=e.x>f.x and 1 or -1
  f.vx=0
  if i.p then tryatk(f,ak.lp) sfx(2)
  elseif i.k and f.cool<=0 then startsp(f)
  elseif not i.d then f.st="id" end
 elseif st=="jp" then
  if i.p or i.k then tryatk(f,ak.ja) sfx(2) end
  f.vx=i.mx*f.md.spd
 elseif st=="at" then
  local a=f.ak
  if f.t>=a.du then f.st="id" f.t=0
  elseif not f.hf and f.t>=a.su and f.t<=a.ae then
   hitchk(f,e,a.x,a.y,a.w,a.h,a.dm,a.kx,a.hs,false,a.sx)
  end
  if airb(f) then f.vx*=.98 else f.vx=0 end
 elseif st=="sp" then
  spup(f,e)
 elseif st=="hs" then
  f.vx*=.85
  if f.t>=f.hst and not airb(f) then f.st="id" f.t=0 end
 elseif st=="kd" then
  f.vx*=.8
  if f.t>=40 then f.st="id" f.t=0 f.inv=40 end
 elseif st=="ko" then
  f.vx*=.98
 elseif st=="lg" then
  f.vx*=.7
  if f.t>=f.lgt then f.st="id" f.t=0 end
 end
 -- physics
 f.x+=f.vx
 if airb(f) or f.vy<0 then
  f.y+=f.vy f.vy+=.3
  if f.y>=gy then
   f.y=gy
   if f.st=="jp" or (f.st=="at" and f.ak==ak.ja) then
    f.st="id" f.t=0 dust(f.x,gy+2,3) sfx(7)
   elseif f.st=="sp" then
    f.st="lg" f.t=0 f.lgt=f.mi==3 and 16 or 10 f.vx=0 dust(f.x,gy+2,3) sfx(7)
   elseif f.st=="hs" then
    f.st="kd" f.t=0 f.vx*=.5 dust(f.x,gy+2,4) sfx(7)
   elseif f.st=="ko" then
    if abs(f.vy)>1 then f.vy*=-.4 sfx(7) dust(f.x,gy+2,4) shk=max(shk,2)
    else f.vy=0 end
   end
  end
 end
 f.x=mid(14,f.x,114)
end

function spup(f,e)
 local m=f.mi
 if m==1 then -- jaguar leap
  if f.t==5 then f.vx=f.fc*3.6 f.vy=-2.6 f.y-=1 end
  if f.t>4 and not f.hf then
   hitchk(f,e,18,26,14,14,12,2.6,22,true,4)
   add(parts,{x=f.x-f.fc*12,y=f.y-28+rnd(16),vx=-f.fc,vy=0,l=8,c=10,r=1})
  end
  if f.t>50 then f.st="id" f.t=0 end
 elseif m==2 then -- electra bolt
  if f.t==10 then
   add(bolts,{x=f.x+f.fc*20,y=f.y-28,vx=f.fc*3,ow=f})
   sfx(9)
  end
  if f.t>=26 then f.st="id" f.t=0 end
 else -- pyros uppercut
  if f.t==6 then f.vy=-5 f.y-=1 end
  if f.t>5 and f.t<24 and not f.hf then
   hitchk(f,e,12,36,14,24,14,2,24,true,4)
  end
  if f.t>5 then
   add(parts,{x=f.x+rnd(16)-8,y=f.y-16-rnd(20),vx=0,vy=-1-rnd(1),l=10,
    c=({8,9,10})[1+flr(rnd(3))],r=1+rnd(1)})
  end
  if f.t>60 then f.st="id" f.t=0 end
 end
end

function blocking(d,a)
 return not airb(d) and d.mx==(d.x<a.x and -1 or 1)
  and (d.st=="id" or d.st=="wk" or d.st=="cr")
end
function hitchk(a,d,ox,oy,w,h,dm,kx,hs,kd,sx)
 local hx,hy=a.x+a.fc*ox,a.y-oy
 if abs(hx-d.x)<w/2+11 and abs(hy-(d.y-24))<h/2+22 then
  a.hf=true
  dohit(a,d,dm,kx,hs,kd,hx,hy,sx)
 end
end
function dohit(a,d,dm,kx,hs,kd,hx,hy,sx)
 if d.inv>0 or d.st=="kd" or d.st=="ko" then return end
 local dir=d.x<a.x and -1 or 1
 if blocking(d,a) then
  d.blk=10 d.vx=dir*kx*.5 d.hp=max(1,d.hp-1)
  sfx(5) spark(hx,hy,4,7,12) hstop=2
  return
 end
 dm=flr(dm*a.md.dmul+.5)
 d.hp-=dm
 d.cmb=(d.st=="hs" or airb(d)) and d.cmb+1 or 1
 d.st="hs" d.t=0 d.hst=hs d.vx=dir*kx
 if kd then d.vy=-3.2 d.y-=1 end
 if airb(d) then d.vy=min(d.vy,-2) end
 sfx(sx)
 spark(hx,hy,3+dm\2,10,7)
 hstop=3+dm\3 shk=min(6,2+dm\3)
 if d.hp<=0 then doko(a,d) end
end
function doko(a,d)
 d.hp=0 d.st="ko" d.t=0
 d.vx=(d.x<a.x and -1 or 1)*3.4 d.vy=-4.2 d.y-=2
 scrap(d) flash=4 shk=10 hstop=8
 sfx(8) sfx(13)
 music(-1)
 sub="ko" subt=0
 say("k.o.!",90)
end

--==== fighter drawing ====
function pose(f)
 local s=f.st
 if s=="id" and airb(f) then return 6
 elseif f.blk>0 then return 10
 elseif s=="wk" then return ({2,1,3,1})[flr(f.t/5)%4+1]
 elseif s=="jp" then return 6
 elseif s=="cr" then return 7
 elseif s=="at" then return f.ak.pz
 elseif s=="hs" then return 9
 elseif s=="kd" or s=="ko" then return 11
 elseif s=="lg" then return 7
 elseif s=="wn" then return 12
 elseif s=="sp" then
  if f.mi==1 then return f.t<5 and 7 or 5
  elseif f.mi==2 then return 13
  else return f.t<6 and 7 or 12 end
 end
 return 1
end
function fdraw(f)
 if f.st=="ko" and f.t%4<2 and f.t>30 then return end
 if f.inv>0 and f.t%4<2 then return end
 local pz=pose(f)
 local sx,sy=((pz-1)%8)*16,((pz-1)\8)*24
 local fl=f.fc==-1
 local yo=(f.st=="id" and f.t%40<20) and 1 or 0
 -- shadow
 ovalfill(f.x-10,gy+2,f.x+10,gy+6,1)
 -- reflection (legs only)
 if arena==1 then
  for i=1,15 do pal(i,1) end
  sspr(sx,sy+12,16,12,f.x-16,gy+3,32,24,fl,true)
  pal()
 end
 setplt(f)
 sspr(sx,sy,16,24,f.x-16,f.y-48+yo,32,48,fl)
 pal()
end

--==== bolts ====
function bup()
 foreach(bolts,function(b)
  b.x+=b.vx
  local d=b.ow==p1 and p2 or p1
  if abs(b.x-d.x)<10 and abs(b.y-(d.y-24))<26 then
   dohit(b.ow,d,8,1.6,16,false,b.x,b.y,14)
   del(bolts,b)
  elseif b.x<-4 or b.x>132 then
   del(bolts,b)
  end
 end)
end
function bdraw()
 foreach(bolts,function(b)
  circfill(b.x,b.y,4,12)
  circfill(b.x,b.y,2,7)
  for i=1,3 do
   line(b.x+rnd(12)-6,b.y+rnd(12)-6,b.x+rnd(6)-3,b.y+rnd(6)-3,rnd(1)<.5 and 7 or 12)
  end
 end)
end

--==== arena ====
function bgdraw()
 if arena==1 then
  -- power plant
  rectfill(0,0,127,47,0)
  for i=0,9 do
   if (i+t\40)%7>0 then pset((i*53)%127,(i*29)%26,i%3==0 and 7 or 5) end
  end
  -- skyline
  for i=0,7 do
   local h=12+(i*37)%22
   rectfill(i*17,48-h,i*17+12,48,1)
   for w=0,3 do
    if (i*7+w*13)%5<2 then pset(i*17+2+w*3,50-h+(w*11)%h,9) end
   end
  end
  fillp(0b0101101001011010.1)
  rectfill(0,42,127,48,0x10)
  fillp()
  rectfill(0,48,127,101,1)
  for yy=60,98,13 do line(0,yy,127,yy,0) end
  line(0,49,127,49,13)
  -- pylons
  for px in all{16,111} do
   rectfill(px-3,34,px+3,101,5)
   rectfill(px-3,34,px+3,36,6)
   rectfill(px-1,40,px+1,98,1)
   pset(px,32,t%30<15 and 8 or 2)
  end
  -- electric arc
  if t%90<6 then
   local ly=35
   local x0=19
   while x0<104 do
    local x1=x0+8+rnd(6)
    local y1=35+rnd(6)-3
    line(x0,ly,x1,y1,rnd(1)<.5 and 7 or 12)
    x0=x1 ly=y1
   end
   if t%90==1 then sfx(14) end
  end
 else
  -- desert dusk
  rectfill(0,0,127,24,1)
  rectfill(0,24,127,38,2)
  circfill(97,36,8,9) circfill(96,35,6,10)
  rectfill(0,38,127,101,4)
  fillp(0b0101101001011010.1)
  rectfill(0,38,127,46,0x24)
  fillp()
  for i=0,3 do
   local dx=i*38-14
   ovalfill(dx,44-(i%2)*4,dx+52,58,2)
  end
  for i=0,5 do
   local rx=(i*43)%120
   ovalfill(rx,86+(i*17)%9,rx+6,90+(i*17)%9,2)
  end
 end
 -- floor
 rectfill(0,102,127,127,arena==1 and 1 or 4)
 line(0,102,127,102,arena==1 and 13 or 9)
 for i=0,4 do
  line(0,106+i*5,127,106+i*5,arena==1 and 5 or 2)
 end
end

--==== hud ====
function bar(x,f,flip)
 local w=48
 rectfill(x-1,4,x+w+1,10,0)
 rect(x-1,4,x+w+1,10,5)
 local hpw=flr(w*max(0,f.hp)/f.md.hp)
 local dw=flr(w*max(0,f.dhp)/f.md.hp)
 local function seg(ww,c)
  if ww>0 then
   if flip then rectfill(x+w-ww,5,x+w,9,c)
   else rectfill(x,5,x+ww,9,c) end
  end
 end
 seg(dw,9)
 seg(hpw,f.hp<f.md.hp*.3 and (t%8<4 and 8 or 2) or 11)
 oprint(f.md.nm,flip and x+w-#f.md.nm*4 or x,12,7,1)
 for i=1,2 do
  local px=flip and x+w-4-(i-1)*7 or x+(i-1)*7+2
  if f.wins>=i then circfill(px,20,2,10) circ(px,20,2,9)
  else circ(px,20,2,5) end
 end
end
function hud()
 bar(4,p1,false)
 bar(76,p2,true)
 -- timer
 rectfill(56,3,71,13,0)
 rect(56,3,71,13,5)
 oprint(timer<10 and "0"..timer or ""..timer,60,6,timer<10 and 8 or 7,1)
 for f in all{p1,p2} do
  if f.cmb>=2 and (f.st=="hs" or f.st=="kd") then
   oprint(f.cmb.." hits!",f==p1 and 84 or 20,28,10,4)
  end
 end
end

--==== scenes ====
function go2(u,d)
 upd=u drw=d t=0
end
function _init()
 dif=2
 menuitem(1,"quit to title",function() gotitle() end)
 gotitle()
end
function _update60() t+=1 upd() end
function _draw() drw() end

--== title ==
function gotitle()
 music(4)
 sel=1
 go2(tup,tdr)
end
function tup()
 if btnp(2) then sel=max(1,sel-1) sfx(0) end
 if btnp(3) then sel=min(3,sel+1) sfx(0) end
 if sel==3 and (btnp(0) or btnp(1)) then dif=dif%3+1 sfx(0) end
 if btnp(4) or btnp(5) then
  if sel<3 then
   mode2p=sel==2
   gosel()
   sfx(1)
  end
 end
end
function tdr()
 cls(0)
 -- grid floor
 for i=0,10 do
  line(64-i*22,127,64-i*7,78,1)
  line(64+i*22,127,64+i*7,78,1)
 end
 for i=0,5 do line(0,78+i*i*2,127,78+i*i*2,1) end
 -- mechs facing off
 for i=1,15 do pal(i,1) end
 spr(0,20,55,2,3)
 spr(0,92,55,2,3,true)
 pal()
 -- logo
 local yy=20+sin(t/90)*2
 bigc("one must",yy,6,5)
 bigc("fall",yy+14,6,5)
 bigc("one must",yy-1,7,5)
 bigc("fall",yy+13,7,5)
 oprint("2 0 9 7",52,yy+27,8,2)
 oprint("a pico-8 demake",34,yy+36,5,1)
 -- menu
 local m={"vs cpu","2 players","skill: "..({"easy","normal","hard"})[dif]}
 for i=1,3 do
  local c=sel==i and 7 or 5
  oprint(m[i],48,72+i*9,c,1)
  if sel==i then oprint(">",42,72+i*9,10,4) end
 end
 if sel==2 then oprint("p2: esdf + shift/a",64,90,5,1) end
 oprint("\142punch \151kick \131\151special",18,110,13,1)
 oprint("hold away to block",28,118,13,1)
end

--== select ==
function gosel()
 pick={1,2}
 pturn=1
 cpuroll=0
 go2(sup,sdr)
end
function sup()
 local pl=pturn-1
 if mode2p or pturn==1 then
  if btnp(0,pl) then pick[pturn]=(pick[pturn]+1)%3+1 sfx(0) end
  if btnp(1,pl) then pick[pturn]=pick[pturn]%3+1 sfx(0) end
  if btnp(4,pl) or btnp(5,pl) then
   sfx(1)
   if pturn==1 then pturn=2
    if not mode2p then cpuroll=40+flr(rnd(20)) end
   else gofight() end
  end
 else
  cpuroll-=1
  if cpuroll%5==0 then pick[2]=pick[2]%3+1 sfx(0) end
  if cpuroll<=0 then gofight() end
 end
end
function sdr()
 cls(0)
 for i=0,127,8 do line(i,0,i,127,1) end
 for i=0,127,8 do line(0,i,127,i,1) end
 bigc("choose your har",6,7,1)
 for i=1,3 do
  local x=8+(i-1)*40
  local m=md[i]
  local mine=pick[1]==i
  local theirs=pturn==2 and pick[2]==i
  rectfill(x,24,x+31,78,0)
  rect(x,24,x+31,78,(mine or theirs) and (mine and 12 or 8) or 5)
  local f={md=m,clash=pturn==2 and theirs and mine}
  setplt(f)
  sspr(0,0,16,24,x,28,32,48)
  pal()
  oprint(m.nm,x+16-#m.nm*2,81,mine and 12 or (theirs and 8 or 6),1)
 end
 local m=md[pick[pturn]]
 oprint(m.tag,64-#m.tag*2,92,7,1)
 -- stats
 local pw=({2,1,3})[pick[pturn]]
 local sp=({2,3,1})[pick[pturn]]
 oprint("pwr",24,101,5,1)
 oprint("spd",24,109,5,1)
 for i=1,3 do
  rectfill(42+i*8,101,46+i*8,105,i<=pw and 8 or 1)
  rectfill(42+i*8,109,46+i*8,113,i<=sp and 11 or 1)
 end
 local who=pturn==1 and "player 1" or (mode2p and "player 2" or "cpu")
 oprint(who.." selecting...",64-7*4,120,pturn==1 and 12 or 8,1)
end

--== fight ==
function gofight()
 arena=1+flr(rnd(2))
 p1=newf(pick[1],0,false)
 p2=newf(pick[2],1,not mode2p)
 p2.clash=pick[1]==pick[2]
 rnum=1
 startround()
 go2(fup2,fdr2)
end
function startround()
 for f,x in pairs{[p1]=30,[p2]=98} do
  f.x=x f.y=-40 f.vx=0 f.vy=0
  f.hp=f.md.hp f.dhp=f.hp
  f.st="id" f.t=0 f.cool=0 f.inv=0 f.cmb=0
 end
 p1.fc=1 p2.fc=-1
 parts={} bolts={}
 timer=60 rt=0
 sub="in" subt=0
 msgt=0
end
function fup2()
 subt+=1
 if hstop>0 then
  hstop-=1
 else
  if sub=="in" then
   for f in all{p1,p2} do
    if f.y<gy then
     f.y=min(gy,f.y+6)
     add(parts,{x=f.x+rnd(12)-6,y=f.y-2,vx=0,vy=1+rnd(1),l=8,c=rnd(1)<.5 and 9 or 10,r=1})
     if f.y>=gy then dust(f.x,gy+2,5) shk=3 sfx(7) end
    end
   end
   if subt==8 then say(arena==1 and "- power plant -" or "- desert dusk -",26,false) end
   if subt==40 then say(p1.wins+p2.wins==2 and "final round" or "round "..rnum) sfx(12) end
   if subt==80 then say("fight!",40) sfx(12) end
   if subt>=90 then
    sub="go"
    music(0)
   end
  elseif sub=="go" then
   fup(p1,p2,true)
   fup(p2,p1,true)
   push()
   bup()
   rt+=1
   if rt%60==0 then
    timer=max(0,timer-1)
    if timer<=5 and timer>0 then sfx(0) end
    if timer==0 then
     music(-1)
     local w=p1.hp>=p2.hp and p1 or p2
     local l=w==p1 and p2 or p1
     say("time up!",60)
     sub="ko" subt=0 kow=w l.st="kd" l.t=-20
    end
   end
   if p1.st=="ko" or p2.st=="ko" then
    kow=p1.st=="ko" and p2 or p1
   end
  elseif sub=="ko" then
   if subt>40 or subt%2==0 then
    fup(p1,p2,false)
    fup(p2,p1,false)
   end
   if subt==55 and kow.hp>=kow.md.hp then say("perfect!",60) sfx(12) end
   if subt==70 then
    kow.wins+=1
    if kow.wins>=2 then
     sub="win" subt=0
     kow.st="wn" kow.t=0
     say(kow.md.nm.." wins!",999)
    else
     rnum+=1
     startround()
    end
   end
  elseif sub=="win" then
   fup(p1,p2,false)
   fup(p2,p1,false)
   if subt>30 then
    if btnp(5) then gofight() sfx(1) end
    if btnp(4) then gosel() sfx(1) end
   end
  end
 end
 pupd()
 shk*=.82
 flash=max(0,flash-1)
 msgt=max(0,msgt-1)
end
function push()
 if abs(p1.x-p2.x)<26 and not airb(p1) and not airb(p2) then
  local d=p1.x<p2.x and 1 or -1
  p1.x-=d*.5 p2.x+=d*.5
 end
end
function fdr2()
 if flash>0 then cls(7) return end
 camera(rnd(shk)-shk/2,rnd(shk)-shk/2)
 bgdraw()
 bdraw()
 fdraw(p1)
 fdraw(p2)
 pdraw()
 camera()
 hud()
 if msgt>0 then
  if mbig then
   local c=msg=="k.o.!" and 8 or 7
   if msgt>30 and t%6<3 then c=msg=="k.o.!" and 7 or 10 end
   bigc(msg,46,c,c==7 and 1 or 2)
  else
   oprint(msg,64-#msg*2,50,7,1)
  end
 end
 if sub=="win" and subt>30 then
  local q=kow.md.qt
  rectfill(12,86,115,102,0)
  rect(12,86,115,102,5)
  oprint('"'..q..'"',64-#q*2-2,89,6,1)
  oprint("\151 rematch  \142 new har",26,96,13,1)
 end
end
