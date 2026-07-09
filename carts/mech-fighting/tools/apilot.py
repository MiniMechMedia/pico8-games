#!/usr/bin/env python3
"""Run the assembled cart in PICO-8 with scripted inputs + screenshots.
Usage: apilot.py <scenario>   (scenarios defined below as lua snippets)"""
import glob
import os
import subprocess
import sys

import os
BUILD = os.path.dirname(os.path.abspath(__file__))
CART = "/Users/nathandunn/Projects/pico8-games/carts/mech-fighting/mech-fighting.p8"
SHOTS = "/Users/nathandunn/Projects/pico8-games/global-screenshots"
PICO8 = "/Applications/PICO-8.app/Contents/MacOS/pico8"

HARNESS_TMPL = """
-- autopilot harness
ap_f=0
ap_cur={{{{}},{{}}}}
ap_prev={{{{}},{{}}}}
local _realu=_update60
btn=function(b,pl) pl=pl or 0 return ap_cur[pl+1][b]==true end
btnp=function(b,pl)
 pl=pl or 0
 return ap_cur[pl+1][b]==true and ap_prev[pl+1][b]~=true
end
{script}
_update60=function()
 ap_prev=ap_cur
 ap_cur=ap_script(ap_f) or {{{{}},{{}}}}
 _realu()
 ap_f+=1
 if ap_shots[ap_f] then extcmd("screen") end
 if ap_f>ap_end then extcmd("shutdown") end
end
"""

SCENARIOS = {
    # full flow: title -> select -> fight vs cpu, jaguar
    "flow": """
function ap_script(f)
 local i={{},{}}
 local function p(b) i[1][b]=true end
 if f==30 then p(5) end
 if f==80 then p(5) end
 if f>=250 and f<290 then p(1) end
 if f==300 or f==322 then p(4) end
 if f==344 then p(5) end
 if f>=366 and f<372 then p(3) p(5) end
 if f>=390 and f<450 and f%9<2 then p(4) end
 if f>=450 and f<600 and f%13<2 then p(5) end
 if f>=450 and f<600 and f%7<3 then p(1) end
 return i
end
ap_shots={} for n in all(split"20,60,160,215,240,258,304,326,348,370,400,440,500,560") do ap_shots[n]=true end
ap_end=620
""",
    # stay on title + select longer for ui shots
    "menus": """
function ap_script(f)
 local i={{},{}}
 local function p(b) i[1][b]=true end
 if f==10 then extcmd("audio_rec") end
 if f==280 then extcmd("audio_end") end
 if f==90 then p(3) end
 if f==100 then p(3) end
 if f==110 then p(1) end
 if f==140 then p(2) end
 if f==150 then p(2) end
 if f==170 then p(5) end
 if f==200 then p(1) end
 if f==230 then p(5) end
 return i
end
ap_shots={} for n in all(split"40,85,120,165,195,225,260,290") do ap_shots[n]=true end
ap_end=300
""",
    # deterministic win: drain p2, capture ko->tally->win screen
    "winscreen": """
function ap_script(f)
 local i={{},{}}
 local function p(b) i[1][b]=true end
 if f==30 then p(5) end
 if f==80 then p(5) end
 if f==210 then extcmd("audio_rec") end
 if f==790 then extcmd("audio_end") end
 if f==260 then p2.hp=5 p1.hp=80 end
 if f>=240 and f<600 then
  local c=f%30
  if c<12 then p(1) elseif c<14 then p(4) end
 end
 if f==620 then p2.hp=4 end
 if f>=640 and f<900 then
  local c=f%30
  if c<12 then p(1) elseif c<14 then p(4) end
 end
 return i
end
ap_shots={} for n in all(split"330,420,470,500,540,570,700,760,820,880,940,1000,1060") do ap_shots[n]=true end
ap_end=1100
""",
    # long cpu fight, electra p1 (bolt specials), watch ko flow
    "kofight": """
function ap_script(f)
 local i={{},{}}
 local function p(b) i[1][b]=true end
 if f>200 and f<210 then arena=1 end
 if f==30 then p(5) end
 if f==60 then p(1) end
 if f==80 then p(5) end
 if f>=240 then
  local c=f%120
  if c<30 then p(1)
  elseif c<36 then p(3) p(5)
  elseif c<60 and c%8<2 then p(4)
  elseif c<80 and c%10<2 then p(5)
  elseif c<100 then p(0)
  end
 end
 return i
end
ap_shots={} for n in all(split"250,400,600,800,1000,1200,1400,1600,1800,2000,2200,2400,2500,2600,2700,2800") do ap_shots[n]=true end
ap_end=2900
""",
}


def main():
    scen = sys.argv[1] if len(sys.argv) > 1 else "flow"
    cart = open(CART).read()
    harness = HARNESS_TMPL.format(script=SCENARIOS[scen])
    test = cart.replace("__gfx__", harness + "\n__gfx__", 1)
    tpath = f"{BUILD}/mftest.p8"
    open(tpath, "w").write(test)
    for f in glob.glob(f"{SHOTS}/mftest_*.png"):
        os.remove(f)
    try:
        subprocess.run([PICO8, "-volume", "32", "-run", tpath],
                       timeout=120, capture_output=True)
    except subprocess.TimeoutExpired:
        print("(timed out, killed)")
    shots = sorted(glob.glob(f"{SHOTS}/mftest_*.png"))
    print(f"{len(shots)} screenshots:")
    for s in shots:
        print(s)


if __name__ == "__main__":
    main()
