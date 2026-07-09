#!/usr/bin/env python3
"""Translate main.lua PICO-8isms to vanilla lua, wrap with an API shim +
input script, run N simulated frames headless to catch runtime errors."""
import re
import subprocess

import os
BUILD = os.path.dirname(os.path.abspath(__file__))

SHIM = r"""
-- pico-8 api shim
_print=print
local _frame=0
local _prev={}
local _cur={}
function _set_inputs(f) _cur=f or {} end
function btn(b,pl) pl=pl or 0 return _cur[pl] and _cur[pl][b] or false end
function btnp(b,pl)
 pl=pl or 0
 local c=_cur[pl] and _cur[pl][b]
 local p=_prev[pl] and _prev[pl][b]
 return (c and not p) or false
end
function _endframe()
 _prev={}
 for k,v in pairs(_cur) do
  local t={} for kk,vv in pairs(v) do t[kk]=vv end
  _prev[k]=t
 end
end
flr=math.floor
abs=math.abs
max=math.max
min=math.min
sqrt=math.sqrt
function mid(a,b,c)
 local t={a,b,c} table.sort(t) return t[2]
end
function sgn(x) return x<0 and -1 or 1 end
function rnd(n)
 if n==nil then n=1 end
 return math.random()*n
end
function srand() end
function sin(x) return -math.sin(x*6.2831853) end
function cos(x) return math.cos(x*6.2831853) end
function add(t,v) t[#t+1]=v return v end
function del(t,v)
 for i=1,#t do if t[i]==v then table.remove(t,i) return end end
end
function deli(t,i) table.remove(t,i) end
function all(t)
 local i=0
 local n=#t
 return function()
  i=i+1
  if i<=n then return t[i] end
 end
end
function foreach(t,f)
 for i=#t,1,-1 do if t[i]~=nil then f(t[i]) end end
end
function count(t) return #t end
function split(s,sep)
 sep=sep or ","
 local out={}
 for tok in string.gmatch(s.."","([^"..sep.."]*)"..sep.."?") do
  if #out>0 or tok~="" or true then
   local n=tonumber(tok)
   out[#out+1]=n or tok
  end
 end
 -- trailing empty from gmatch pattern: trim one if source doesn't end with sep
 if out[#out]=="" and s:sub(-1)~=sep then out[#out]=nil end
 return out
end
function tostr(v) return tostring(v) end
function tonum(v) return tonumber(v) end
local function nop() end
cls=nop spr=nop sspr=nop pset=nop pget=nop line=nop rect=nop rectfill=nop
circ=nop circfill=nop ovalfill=nop oval=nop print=nop pal=nop palt=nop
fillp=nop camera=nop music=nop sfx=nop menuitem=nop cartdata=nop color=nop
map=nop mget=nop dget=nop dset=nop
t_=nop
function time() return _frame/60 end
math.randomseed(42)
"""

RUNNER = r"""
-- run scripted frames
_init()
local function press(b) return {[0]={[b]=true}} end
local dirs={[0]=true}
local err_at=nil
local log={}
local function step(inp)
 _set_inputs(inp)
 local ok,e=pcall(_update60)
 if not ok then error("update f".._frame..": "..tostring(e)) end
 ok,e=pcall(_draw)
 if not ok then error("draw f".._frame..": "..tostring(e)) end
 _endframe()
 _frame=_frame+1
end
-- title: wait, then confirm (vs cpu)
for i=1,30 do step({}) end
step(press(5))
for i=1,10 do step({}) end
-- select: p1 move right once, confirm
step(press(1))
for i=1,5 do step({}) end
step(press(5))
-- cpu roll
for i=1,80 do step({}) end
assert(upd~=nil)
-- fight: intro
for i=1,100 do step({}) end
_print("after intro: sub="..tostring(sub).." p1st="..tostring(p1.st))
-- fight: mash inputs for a while
math.randomseed(7)
for i=1,1800 do
 local inp={[0]={}}
 local r=math.random()
 if r<0.3 then inp[0][1]=true
 elseif r<0.4 then inp[0][0]=true
 elseif r<0.5 then inp[0][4]=true
 elseif r<0.6 then inp[0][5]=true
 elseif r<0.65 then inp[0][3]=true inp[0][5]=true
 elseif r<0.7 then inp[0][2]=true end
 step(inp)
end
_print("after brawl: sub="..tostring(sub).." p1hp="..p1.hp.." p2hp="..p2.hp..
 " p1w="..p1.wins.." p2w="..p2.wins.." rnum="..tostring(rnum).." timer="..tostring(timer))
-- run long enough to hit timeout / ko flows across rounds
for i=1,9000 do
 local inp={[0]={}}
 if i%3==0 then inp[0][4]=true end
 if i%7<3 then inp[0][1]=true end
 if i%31==0 then inp[0][3]=true inp[0][5]=true end
 step(inp)
 if sub=="win" then break end
end
_print("end: sub="..tostring(sub).." p1w="..(p1 and p1.wins or -1).." p2w="..(p2 and p2.wins or -1))
-- victory screen: rematch then back to select
for i=1,40 do step({}) end
step(press(4))
for i=1,30 do step({}) end
_print("shim test passed. scene t="..t)
"""


def translate(src):
    src = src.replace("!=", "~=")
    src = src.replace("\\^", "")  # p8scii control codes
    # compound assignment: rewrite prefix only, RHS left in place
    src = re.sub(r"([A-Za-z_][\w.\[\]]*)\s*([+\-*/])=", r"\1=\1\2", src)
    # integer division a\b  (avoid string escapes like \^)
    src = re.sub(r"([\w)])\s*\\\s*([\w(])", r"\1//\2", src)

    # binary literals
    def bin2dec(m):
        s = m.group(1)
        ip = s.split(".")[0]
        return str(int(ip, 2) if ip else 0)

    src = re.sub(r"0b([01]+(?:\.[01]+)?)", bin2dec, src)
    return src


def main():
    lua = open(f"{BUILD}/main.lua").read()
    full = SHIM + "\n" + translate(lua) + "\n" + RUNNER
    open(f"{BUILD}/_shimtest.lua", "w").write(full)
    r = subprocess.run(["lua", f"{BUILD}/_shimtest.lua"],
                       capture_output=True, text=True, timeout=120)
    print(r.stdout)
    if r.returncode != 0:
        print("FAIL:\n" + r.stderr)
        raise SystemExit(1)


if __name__ == "__main__":
    main()
