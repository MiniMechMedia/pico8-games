#!/usr/bin/env python3
"""Generate __sfx__ and __music__ sections and splice them into the-olympian.p8.

sfx note = 5 hex chars: pitch(2) wave(1) vol(1) effect(1)
waves: 0 tri 1 tsaw 2 saw 3 sqr 4 pulse 5 organ 6 noise 7 phaser
fx: 0 none 1 slide 2 vib 3 drop 4 fadein 5 fadeout 6 arp+ 7 arp-
music line = "FF AABBCCDD"; 0x40 bit on a channel byte = muted

music(0)=title  music(8)=fire  music(16)=warm end  music(24)=ash
"""
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CART = os.path.join(ROOT, 'the-olympian.p8')


def N(p, w, v, fx=0):
    return f'{p:02x}{w:x}{v:x}{fx:x}'


REST = '00000'


def sfx(speed, notes, loop=(0, 0)):
    notes = (notes + [REST] * 32)[:32]
    return f'00{speed:02x}{loop[0]:02x}{loop[1]:02x}' + ''.join(notes)


def seq(pairs):
    """pairs: list of (slot, note); fill rest with REST over 32 slots."""
    out = [REST] * 32
    for slot, note in pairs:
        out[slot] = note
    return out


# note numbers: C0=0, +12 per octave
C1, D1, Eb1, F1, G1, A1, Bb1 = 12, 14, 15, 17, 19, 21, 22
C2, D2, E2, F2, G2, A2, Bb2 = 24, 26, 28, 29, 31, 33, 34
C3, D3, Eb3, E3, F3, Fs3, G3, A3, Bb3, B3 = 36, 38, 39, 40, 41, 42, 43, 45, 46, 47
C4, D4, E4, F4 = 48, 50, 52, 53

S = [None] * 32

# ---- ui / engine sfx -------------------------------------------------
S[0] = sfx(3, [N(56, 5, 1), N(60, 5, 1, 5)])                      # typewriter blip
S[1] = sfx(2, [N(48, 5, 2), N(48, 5, 1, 5)])                      # choice move
S[2] = sfx(4, [N(48, 5, 3), N(55, 5, 3), N(60, 5, 2, 5)])         # confirm
S[3] = sfx(4, [N(30, 6, 2), N(24, 6, 2, 3), N(18, 6, 1, 5)])      # page turn
S[4] = sfx(2, [N(40, 7, 4), N(20, 7, 5, 3), N(50, 7, 4, 2),
               N(10, 6, 5, 3), N(35, 7, 3), N(15, 6, 2, 5)])      # glitch burst

# ---- title theme (speed 24, d minor hymn) ----------------------------
pad = lambda p, n: [N(p, 5, 2)] * n
S[16] = sfx(24, pad(D2, 16) + pad(Bb1, 8) + pad(C2, 8))           # pad prog
S[17] = sfx(24, seq([(0, N(A3, 0, 4)), (6, N(G3, 0, 3)), (8, N(F3, 0, 4, 2)),
                     (16, N(E3, 0, 3)), (20, N(F3, 0, 3)), (24, N(D3, 0, 4, 2))]))
S[18] = sfx(24, seq([(0, N(D1, 6, 3, 3)), (8, N(50, 6, 1, 5)),
                     (16, N(D1, 6, 2, 3)), (24, N(50, 6, 1, 5))]))  # slow pulse
S[19] = sfx(24, seq([(0, N(D4, 0, 4)), (6, N(C4, 0, 3)), (8, N(A3, 0, 4, 2)),
                     (16, N(G3, 0, 3)), (20, N(E3, 0, 3)), (24, N(D3, 0, 5, 2))]))

# ---- fire theme (speed 20, f lydian, warm awe) -----------------------
S[20] = sfx(20, pad(F2, 8) + pad(G2, 8) + pad(A2, 8) + pad(G2, 8))
S[21] = sfx(20, [N(F3, 5, 2), N(A3, 5, 2), N(C4, 5, 2), N(E4, 5, 2)] * 8)
S[22] = sfx(20, seq([(0, N(C4, 0, 4)), (8, N(A3, 0, 3)), (12, N(B3, 0, 3)),
                     (16, N(G3, 0, 3)), (24, N(F3, 0, 4, 2))]))

# ---- warm ending (speed 24, d major picardy) -------------------------
S[23] = sfx(24, pad(D2, 8) + pad(G1, 8) + pad(A1, 8) + pad(D2, 8))
S[24] = sfx(24, seq([(0, N(Fs3, 0, 4)), (8, N(A3, 0, 4)), (16, N(G3, 0, 3)),
                     (20, N(E3, 0, 3)), (24, N(D3, 0, 5, 2))]))

# ---- ash ending (speed 26, dark drone) -------------------------------
S[25] = sfx(26, [N(D1, 2, 2)] * 12 + [N(Eb1, 2, 2)] * 4 +
                [N(D1, 2, 2)] * 12 + [N(C1, 2, 2)] * 4)
S[26] = sfx(26, seq([(0, N(D3, 0, 3)), (12, N(Eb3, 0, 3, 2)), (28, N(A2, 0, 2))]))

SILENT = sfx(16, [])
MUTED = '00 40414243'


def sfx_section():
    hi = max(i for i, s in enumerate(S) if s)
    return '__sfx__\n' + '\n'.join(s or SILENT for s in S[:hi + 1]) + '\n'


def music_section():
    pats = {
        0: ('01', [16, 17, 18]),   # title loop a
        1: ('02', [16, 19, 18]),   # title loop b
        8: ('03', [20, 21, 22]),   # fire loop
        16: ('03', [23, 24]),      # warm end loop
        24: ('03', [25, 26]),      # ash loop
    }
    out = []
    for i in range(25):
        if i in pats:
            flags, chans = pats[i]
            chans = chans + [0x40 + j for j in range(len(chans), 4)]
            out.append(flags + ' ' + ''.join(f'{c:02x}' for c in chans[:4]))
        else:
            out.append(MUTED)
    return '__music__\n' + '\n'.join(out) + '\n'


if __name__ == '__main__':
    cart = open(CART).read()
    for sec in ('__sfx__', '__music__'):
        if sec in cart:
            cart = cart.split(sec)[0].rstrip() + '\n'
    cart = cart.rstrip() + '\n' + sfx_section() + music_section()
    open(CART, 'w').write(cart)
    print('spliced audio into', CART)
