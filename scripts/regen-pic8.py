"""Regenerate pic8 menu entries using p8export's Pic8CompilationTarget.

Run with the p8export venv from the p8export repo root:
    cd ~/Projects/p8export3/p8export-fresh
    venv/bin/python ~/Projects/pico8-games/scripts/regen-pic8.py
"""
import re
import sys
from pathlib import Path
from types import SimpleNamespace

sys.path.insert(0, str(Path.home() / 'Projects/p8export3/p8export-fresh'))
from src.Pic8CompilationTarget import Pic8CompilationTarget
from src.ParsedContents import CartType, ControlEnum, ParsedLabelImage
from src.pico8fileparser import Pico8FileParser

CARTS = Path(__file__).resolve().parent.parent / 'carts'
PIC8 = CARTS / 'pic8' / 'pic8.p8'

# Carts with the p8export metadata block. Tweets get their entries removed.
EXPORTED = [
    # labels used the extended palette and were decoding corrupted
    'graphics-with-pico-8',
    'northern-corridor',
    'terrain-generator',
    # removed earlier because of the corruption bug
    'spray-ya-later-litigator',
    'toadally-normal-matching-game',
]

# Carts without the metadata block
CUSTOM = [
    dict(
        slug='mech-fighting',
        name='One Must Fall: PICO',
        tagline='Giant robots. One pilot walks away.',
        controls=[
            ([ControlEnum.ARROW_KEYS], 'walk / jump / crouch'),
            ([ControlEnum.Z], 'punch'),
            ([ControlEnum.X], 'kick'),
            ([ControlEnum.DOWN_ARROW_KEY, ControlEnum.X], 'special move'),
        ],
    ),
    dict(
        slug='the-olympian',
        name='The Olympian',
        tagline='The titans are gone. Inherit the fire.',
        controls=[
            ([ControlEnum.X], 'advance text / select choice'),
            ([ControlEnum.UP_ARROW_KEY, ControlEnum.DOWN_ARROW_KEY], 'change choice'),
        ],
    ),
    dict(
        slug='tic-tac-toe',
        name='Out of Hand',
        tagline='A tic-tac-toe boss fight',
        controls=[
            ([ControlEnum.MOUSE, ControlEnum.ARROW_KEYS], 'move cursor'),
            ([ControlEnum.LEFT_CLICK, ControlEnum.X], 'place mark'),
        ],
    ),
]


def compile_entry(parsed):
    Pic8CompilationTarget.compileToPic8Cart(
        config=None, parsedContents=parsed, pic8CartInputPath=PIC8
    )


def custom_parsed(info):
    p8 = CARTS / info['slug'] / f"{info['slug']}.p8"
    label = p8.read_text().split('__label__')[1].split('__')[0].strip()
    return SimpleNamespace(
        cartRelativePath=f"/carts/{info['slug']}/{info['slug']}.p8",
        labelImage=ParsedLabelImage(label),
        metadata=SimpleNamespace(
            game_name=info['name'],
            tagline=info['tagline'],
            correctedGameSlug=info['slug'],
            stronglyTypedCartType=CartType.GAME,
            controls=[
                SimpleNamespace(inputs=inputs, desc=desc)
                for inputs, desc in info['controls']
            ],
        ),
    )


def main():
    # Drop tweet entries first to get back under the char limit
    present = re.findall(r'-- begin (\S+)\n', PIC8.read_text())
    for slug in present:
        parsed = Pico8FileParser.parse(CARTS / slug / f'{slug}.p8')
        if parsed.metadata.stronglyTypedCartType == CartType.TWEET:
            print(f'removing tweet {slug}')
            compile_entry(parsed)

    for slug in EXPORTED:
        print(f'adding {slug}')
        compile_entry(Pico8FileParser.parse(CARTS / slug / f'{slug}.p8'))

    for info in CUSTOM:
        print(f"adding {info['slug']}")
        compile_entry(custom_parsed(info))


if __name__ == '__main__':
    main()
