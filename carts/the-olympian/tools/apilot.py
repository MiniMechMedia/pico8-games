#!/usr/bin/env python3
"""Drive the-olympian.p8 with an auto-player + screenshots.

The harness reads engine globals (mode/tstate/fadev) and presses buttons:
X to advance, and at each choice block it picks from a preset option list.

Usage: apilot.py <scenario>|all
Scenarios map to expected endings; the run fails loudly on mismatch.
"""
import glob
import os
import subprocess
import sys

TOOLS = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(TOOLS)
CART = os.path.join(ROOT, 'the-olympian.p8')
SHOTS = '/Users/nathandunn/Projects/pico8-games/global-screenshots'
PICO8 = '/Applications/PICO-8.app/Contents/MacOS/pico8'

HARNESS = '''
-- autopilot harness
ap_f=0
ap_cur={{}}
ap_prev={{}}
ap_ci=0
ap_downs=0
ap_armed=false
ap_choices=split"{choices}"
ap_reported=false
printh("start","aplog",true)
function lg(m) printh(m) printh(m,"aplog") end
local _gn=nil
btn=function(b,pl) return ap_cur[b]==true end
btnp=function(b,pl) return ap_cur[b]==true and ap_prev[b]~=true end
-- keep test runs from polluting real save data (endings counter)
dset=function() end
dget=function() return 0 end
local _realgoto=goto_node
goto_node=function(id)
	lg("!!node "..id)
	_realgoto(id)
end
function ap_script(f)
	local i={{}}
	if f%120==0 then lg("!!f "..f.." mode "..tostr(mode).." tstate "..tostr(tstate).." fadev "..tostr(fadev)) end
	if end_banner and not ap_reported then
		lg("!!ending "..end_banner)
		ap_reported=true
		ap_bshot=ap_f+30
	end
	if ap_bshot and ap_f==ap_bshot then extcmd("screen") end
	if f==10 and {audio_rec}==1 then extcmd("audio_rec") end
	if f==900 and {audio_rec}==1 then extcmd("audio_end") end
	if f<{title_wait} then return i end
	if f%4~=0 then return i end
	if mode=='title' then
		if ap_ci>0 then
			lg("!!done")
			extcmd("shutdown")
		end
		i[5]=true
		return i
	end
	if fadev~=0 then return i end
	if tstate=='choice' then
		if ap_downs>0 then
			i[3]=true
			ap_downs-=1
			return i
		end
		if not ap_armed then
			ap_ci+=1
			ap_downs=(ap_choices[ap_ci] or 1)-1
			lg("!!choice #"..ap_ci.." pick "..(ap_choices[ap_ci] or 1).." of "..#choices)
			ap_armed=true
			if ap_downs>0 then
				i[3]=true
				ap_downs-=1
			end
			return i
		end
		i[5]=true
		ap_armed=false
	else
		i[5]=true
	end
	return i
end
local _realu=_update
_update=function()
	ap_prev=ap_cur
	ap_cur=ap_script(ap_f) or {{}}
	_realu()
	ap_f+=1
	if ap_f%{shot_every}==0 and ap_f<{shot_until} then extcmd("screen") end
	if ap_f>{max_frames} then
		lg("!!timeout")
		extcmd("shutdown")
	end
end
'''

# choice lists: tests, stance, partition, canon, fire  (1-based option picks)
SCENARIOS = {
    # picks: tests, mirror, stance, partition, canon, nights, thread,
    #        nights2, thread2, patron, fire
    'hearth':  {'choices': '1,1,1,1,1,1,1,1,1,1,1', 'ending': 1},
    'torch':   {'choices': '2,2,2,2,2,2,2,2,2,2,2', 'ending': 2},
    'olympus': {'choices': '2,1,1,2,2,3,2,1,3,3,3', 'ending': 3},
    'ash':     {'choices': '1,3,3,1,1,3,1,2,2,1,3', 'ending': 4},
    'dream':   {'choices': '1,2,2,3,3,1,3,1,1,2,3', 'ending': 5},
    'chair':   {'choices': '1,2,1,1,2,1,2,1,1,3,3', 'ending': 6},
    'hound':   {'choices': '1,1,3,1,2,3,1,2,2,1,4', 'ending': 7},
}



def run(name, shot_every=9999, shot_until=0, title_wait=0, audio_rec=0, pico_flag='-x', kill_after=180):
    scen = SCENARIOS[name]
    cart = open(CART).read()
    harness = HARNESS.format(choices=scen['choices'], shot_every=shot_every,
                             shot_until=shot_until, max_frames=6000,
                             title_wait=title_wait, audio_rec=audio_rec)
    tpath = os.path.join(ROOT, 'olytest.p8')
    # harness must land inside the __lua__ section, before data sections
    if '\n__sfx__' in cart:
        cart = cart.replace('\n__sfx__', '\n' + harness + '\n__sfx__', 1)
    else:
        cart = cart + harness
    open(tpath, 'w').write(cart)
    for f in glob.glob(f'{SHOTS}/olytest_*.png'):
        os.remove(f)
    try:
        p = subprocess.run([PICO8, '-volume', '16', pico_flag, tpath],
                           timeout=kill_after, capture_output=True, text=True)
        out = p.stdout
    except subprocess.TimeoutExpired as e:
        out = (e.stdout or b'').decode(errors='replace')
        print(f'{name}: TIMED OUT (killed). output tail:')
        print('\n'.join(out.splitlines()[-15:]))
        return False
    endings = [int(l.split()[1]) for l in out.splitlines() if l.startswith('!!ending')]
    ok = endings == [scen['ending']] and '!!done' in out
    status = 'ok' if ok else 'FAIL'
    print(f'{name}: {status} (got endings {endings}, expected [{scen["ending"]}])')
    if not ok:
        tail = [l for l in out.splitlines() if not l.startswith('!!')][-10:]
        print('\n'.join(tail))
    shots = sorted(glob.glob(f'{SHOTS}/olytest_*.png'))
    if shots:
        print(f'{len(shots)} screenshots: {shots[0]} ..')
    return ok


if __name__ == '__main__':
    which = sys.argv[1] if len(sys.argv) > 1 else 'all'
    if which == 'audio':
        # -run has working audio; wav saves at audio_end before the kill
        run('hearth', title_wait=200, audio_rec=1, pico_flag='-run', kill_after=50)
        sys.exit(0)
    if which == 'shots':
        # visual pass: walk a path with periodic screenshots
        name = sys.argv[2] if len(sys.argv) > 2 else 'dream'
        sys.exit(0 if run(name, shot_every=32, shot_until=6000, title_wait=160) else 1)
    names = list(SCENARIOS) if which == 'all' else [which]
    results = [run(n) for n in names]
    sys.exit(0 if all(results) else 1)
