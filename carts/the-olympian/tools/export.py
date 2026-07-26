#!/usr/bin/env python3
"""Build export/: flatten #includes, then pico8-export html + binaries
with the image data carts bundled.

Usage: python export.py
"""
import os
import subprocess

TOOLS = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(TOOLS)
PICO8 = '/Applications/PICO-8.app/Contents/MacOS/pico8'
EXPORT = os.path.join(ROOT, 'export')


def flatten(cart_path, out_path):
    out = []
    with open(cart_path) as f:
        for line in f:
            if line.startswith('#include'):
                inc = line.replace('#include', '').strip()
                with open(os.path.join(ROOT, inc)) as incf:
                    out.append(incf.read() + '\n')
            else:
                out.append(line)
    with open(out_path, 'w') as f:
        f.write(''.join(out))


if __name__ == '__main__':
    os.makedirs(EXPORT, exist_ok=True)
    flat = os.path.join(EXPORT, 'the-olympian.p8')
    flatten(os.path.join(ROOT, 'the-olympian.p8'), flat)
    import glob as _g
    extras = sorted(os.path.basename(f) for f in _g.glob(os.path.join(ROOT, 'oly_img*.p8')))
    for extra in extras:
        with open(os.path.join(ROOT, extra)) as src, \
             open(os.path.join(EXPORT, extra), 'w') as dst:
            dst.write(src.read())
    for target in ('the-olympian.html', 'the-olympian.bin'):
        r = subprocess.run(
            [PICO8, flat, '-export',
             f'{target} ' + ' '.join(extras)],
            capture_output=True, text=True, timeout=120, cwd=EXPORT)
        print(target, '->', r.returncode, (r.stdout or r.stderr).strip()[-200:])
