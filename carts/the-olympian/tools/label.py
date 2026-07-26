#!/usr/bin/env python3
"""Generate the cart __label__ from a title screenshot and splice it in.

Usage: python label.py <screenshot.png>
Label chars: 0-f = colors 0-15, g-v = secret colors 128-143.
"""
import os
import sys

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CART = os.path.join(ROOT, 'the-olympian.p8')

PICO_PALETTE_HEX = '''
#000000 #1d2b53 #7e2553 #008751 #ab5236 #5f574f #c2c3c7 #fff1e8
#ff004d #ffa300 #ffec27 #00e436 #29adff #83769c #ff77a8 #ffccaa
#291814 #111d35 #422136 #125359 #742f29 #49333b #a28879 #f3ef7d
#be1250 #ff6c24 #a8e72e #00b543 #065ab5 #754665 #ff6e59 #ff9d81
'''.split()
PICO_RGB = [(int(x[1:3], 16), int(x[3:5], 16), int(x[5:7], 16)) for x in PICO_PALETTE_HEX]
CHARS = '0123456789abcdefghijklmnopqrstuv'


def nearest(px):
    return min(range(32), key=lambda i: sum((a - b) ** 2 for a, b in zip(PICO_RGB[i], px)))


img = Image.open(sys.argv[1]).convert('RGB').resize((128, 128), Image.NEAREST)
pix = img.load()
lines = []
for y in range(128):
    lines.append(''.join(CHARS[nearest(pix[x, y])] for x in range(128)))
label = '__label__\n' + '\n'.join(lines) + '\n\n'

cart = open(CART).read()
if '__label__' in cart:
    pre, rest = cart.split('__label__', 1)
    post = rest.split('\n\n', 1)[1] if '\n\n' in rest else ''
    cart = pre + post
cart = cart.replace('__sfx__', label + '__sfx__', 1)
open(CART, 'w').write(cart)
print('label spliced')
