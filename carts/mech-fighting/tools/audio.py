#!/usr/bin/env python3
"""Generate __sfx__ and __music__ for the OMF demake.

sfx note = 5 hex chars: pitch(2) wave(1) vol(1) effect(1)
waves: 0 tri 1 tsaw 2 saw 3 sqr 4 pulse 5 organ 6 noise 7 phaser
fx: 0 none 1 slide 2 vib 3 drop 4 fadein 5 fadeout 6 arp+ 7 arp-
music line = "FF AABBCCDD", 0x40 bit on channel byte = muted
"""


def N(p, w, v, fx=0):
    return f"{p:02x}{w:x}{v:x}{fx:x}"


REST = "00000"


def sfx(speed, notes, loop=(0, 0)):
    notes = (notes + [REST] * 32)[:32]
    return f"00{speed:02x}{loop[0]:02x}{loop[1]:02x}" + "".join(notes)


# note numbers: C0=0 .. C1=12 C2=24 C3=36 C4=48
C1, D1, F1, G1, A1, Bb1 = 12, 14, 17, 19, 21, 22
C2, D2, E2, F2, G2, A2, Bb2 = 24, 26, 28, 29, 31, 33, 34
C3, D3, E3, F3, G3, A3, Bb3 = 36, 38, 40, 41, 43, 45, 46
C4, D4, E4, F4, G4, A4 = 48, 50, 52, 53, 55, 57

S = [None] * 32  # sfx slots

# ---- gameplay sfx ----------------------------------------------------
S[0] = sfx(4, [N(48, 3, 4), N(52, 3, 3)])                       # menu move
S[1] = sfx(4, [N(48, 3, 5), N(55, 3, 5), N(60, 3, 4, 5)])       # menu ok
S[2] = sfx(3, [N(40, 6, 3, 3), N(30, 6, 2, 3), N(20, 6, 1, 5)])  # whiff
S[3] = sfx(3, [N(22, 6, 7), N(14, 6, 6, 3), N(10, 3, 4, 3), N(8, 6, 2, 5)])  # hit light
S[4] = sfx(4, [N(16, 6, 7), N(10, 6, 7, 3), N(6, 3, 6, 3), N(6, 6, 4, 3), N(4, 6, 2, 5)])  # hit heavy
S[5] = sfx(3, [N(51, 3, 6), N(38, 6, 4, 3), N(30, 6, 2, 5)])    # block clank
S[6] = sfx(4, [N(20, 4, 4), N(26, 4, 4, 1), N(33, 4, 3, 1), N(38, 4, 2, 5)])  # jump
S[7] = sfx(4, [N(10, 6, 5), N(6, 6, 3, 3), N(4, 6, 1, 5)])      # land thud
S[8] = sfx(8, [N(24, 6, 7), N(18, 6, 7), N(14, 6, 7, 3), N(20, 6, 6), N(12, 6, 6, 3),
               N(8, 6, 5, 3), N(10, 6, 4), N(6, 6, 4, 3), N(4, 6, 3, 5), N(2, 6, 2, 5),
               N(2, 6, 1, 5)])                                   # KO explosion
S[9] = sfx(3, [N(55, 7, 5), N(50, 7, 5, 2), N(58, 7, 4, 2), N(52, 7, 3, 2),
               N(56, 7, 2, 5)])                                  # electra zap
S[10] = sfx(3, [N(14, 2, 5), N(20, 2, 6, 1), N(26, 2, 6, 1), N(33, 2, 5, 1),
                N(38, 1, 4, 5)])                                 # jaguar dash roar
S[11] = sfx(4, [N(8, 6, 5), N(14, 6, 6, 1), N(20, 6, 6, 1), N(26, 6, 6, 1),
                N(33, 6, 5, 1), N(38, 6, 4, 5)])                 # pyros flame rise
S[12] = sfx(6, [N(D2, 3, 6), N(D2, 3, 5), N(A2, 3, 6), N(D3, 3, 6), N(D3, 3, 4, 5)])  # round sting
S[13] = sfx(9, [N(D2, 3, 7), N(D2, 3, 6, 3), N(D1, 3, 7, 3), N(D1, 3, 5, 5),
                N(D1, 6, 3, 5)])                                 # KO sting
S[14] = sfx(3, [N(45, 6, 4), N(52, 7, 4, 3), N(40, 6, 2, 5)])   # bolt hit fizz

# ---- fight music (speed 14, Dm) -------------------------------------
kick = N(6, 6, 7, 3)
snr = N(33, 6, 5, 5)
hat = N(56, 6, 2, 5)


def bass(seq):
    return [N(p, 2, v) if p else REST for p, v in seq]


groove = lambda root, alt: [
    (root, 6), (0, 0), (root, 4), (0, 0), (root, 6), (0, 0), (alt, 5), (0, 0),
    (root, 6), (0, 0), (root, 4), (root, 4), (alt, 5), (0, 0), (root, 6), (0, 0)]

S[16] = sfx(14, bass(groove(D2, A1) + groove(D2, C2)))           # bass A
drum_bar = [kick, REST, hat, REST, snr, REST, hat, hat,
            kick, REST, kick, hat, snr, REST, hat, N(50, 6, 3, 5)]
S[17] = sfx(14, drum_bar * 2)                                    # drums
arp = lambda a, b, c, d: [N(a, 5, 3), N(b, 5, 3), N(c, 5, 3), N(d, 5, 3)]
S[18] = sfx(14, (arp(D3, F3, A3, D4) + arp(F3, A3, D4, F3)) * 2)  # lead A
S[19] = sfx(14, bass(groove(Bb1, F1) + groove(C2, G1)))          # bass B
S[20] = sfx(14, arp(Bb2, D3, F3, Bb3) * 2 + arp(C3, E3, G3, C4) * 2)  # lead B
mel = [N(D4, 3, 4), REST, REST, REST, N(F4, 3, 4), REST, N(E4, 3, 4), REST,
       N(D4, 3, 4), REST, REST, REST, N(C4, 3, 4), REST, N(A3, 3, 4), REST,
       N(Bb3, 3, 4), REST, REST, REST, N(A3, 3, 4), REST, N(G3, 3, 4), REST,
       N(A3, 3, 5, 2), REST, REST, REST, REST, REST, REST, REST]
S[21] = sfx(14, mel)                                             # fight melody

# ---- title music (speed 20, brooding) --------------------------------
pad = lambda p: [N(p, 5, 2)] * 8
S[22] = sfx(20, pad(D2) + pad(F2) + pad(C2) + pad(D2))           # title pad
tmel = [N(D3, 0, 5), REST, REST, REST, REST, REST, N(F3, 0, 4), REST,
        N(E3, 0, 5, 2), REST, REST, REST, REST, REST, REST, REST,
        N(G3, 0, 4), REST, N(F3, 0, 4), REST, N(E3, 0, 4), REST, N(F3, 0, 4), REST,
        N(D3, 0, 5, 2), REST, REST, REST, REST, REST, REST, REST]
S[23] = sfx(20, tmel)                                            # title melody
tdrum = ([N(6, 6, 4, 3)] + [REST] * 7) * 4
S[24] = sfx(20, tdrum)                                           # title pulse

SILENT = sfx(16, [])


def sfx_section():
    hi = max(i for i, s in enumerate(S) if s)
    lines = [(s or SILENT) for s in S[:hi + 1]]
    return "__sfx__\n" + "\n".join(lines) + "\n"


def music_section():
    pats = [
        ("01", [16, 17, 18]),        # fight loop start
        ("00", [16, 17, 21]),
        ("00", [19, 17, 20]),
        ("02", [16, 17, 18]),        # fight loop end
        ("01", [22, 23, 24]),        # title loop
        ("02", [22, 23]),
    ]
    out = []
    for flags, chans in pats:
        chans = chans + [0x40 + i for i in range(1, 5 - len(chans) + 1)]
        out.append(flags + " " + "".join(f"{c:02x}" for c in chans[:4]))
    return "__music__\n" + "\n".join(out) + "\n\n"


if __name__ == "__main__":
    open("sfx.txt", "w").write(sfx_section() + music_section())
    print("ok — fight music: music(0), title: music(4)")
