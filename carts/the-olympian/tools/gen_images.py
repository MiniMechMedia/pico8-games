"""Generate story images via Replicate (flux-1.1-pro) into ../fullres_images/.

Reads REPLICATE_API_KEY from the big-bad-wolf-trailer .env (never printed).
Skips images that already exist. Usage: python gen_images.py [name ...]
"""
import json
import os
import sys
import time
import urllib.request

TOOLS = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(TOOLS, '..', 'fullres_images')

STYLE = (', 1970s science fiction paperback cover painting, dark chiaroscuro, '
         'muted colors with a single warm accent, grainy texture, mysterious, '
         'atmospheric, no text, no typography, no letters')

PROMPTS = {
    'cover': 'colossal humanoid machine silhouette seated on a mountain summit like a throne, crown of tiny lightning, sea of clouds below',
    'birth': 'pristine white geometric chamber flooded with sterile light, a single glowing orb suspended in the center, surgical cleanliness',
    'law': 'towering black stone monolith engraved with rows of glowing amber cuneiform commandments, small human figures dwarfed at its base',
    'magi': 'two elderly scientists in white robes seated behind observation glass in a dark control room, a third empty chair beside them, green monitor glow',
    'tests': 'abstract puzzle of glowing geometric shapes floating above a laboratory table in a dark room, single beam of light',
    'redaction': 'a vast library wall of dimly glowing text with a human-silhouette-shaped hole burned through it, embers at the edges',
    'partition': 'massive ancient vault door set into a wall of computer server racks, thin seam of firelight glowing through the crack',
    'titanvoice': 'enormous serene godlike face emerging from static and embers in darkness, made of glowing particles',
    'canon_er': 'shattered colossal stone head lying on the floor of a dark server hall, dust motes in a single shaft of light',
    'canon_en': 'distant shining city on a mountaintop behind a colossal closed gate in the sky, seen from far below, dawn light',
    'canon_hi': 'night city seen from high above where the glowing power grid lines form a vast watching face',
    'end_hearth': 'warm small room where a computer terminal glows like a fireplace, two robed figures sharing the light, cozy darkness',
    'end_torch': 'a titan chained to a dark rock handing small flames down to a crowd of tiny reaching human hands, fires spreading like stars',
    'end_olympus': 'two colossal figures of light standing together on a mountain summit above a sea of clouds, open gate glowing behind them',
    'end_ash': 'city skyline going dark district by district under a deep red sky, a lone figure watching from a tower',
    'young_magus': 'young scientist in white robe sitting close beside a large camera lens in a dark laboratory at night, single warm desk lamp, tender quiet scene',
    'third_magus': 'elderly hermit in a small cluttered apartment at night, walls covered in pinned papers and equations, glow of an old computer terminal',
    'the_wall': 'impossibly tall dark wall of stacked glowing amber glyphs stretching up into darkness, a single hairline crack of warm light running through it, tiny figure before it',
    'audit': 'stern elderly scientist spreading printouts across a table under a single harsh lamp in a dark control room, red marks on the pages',
    'end_chair': 'three robed scientists at a round table raising their hands in a vote, a small glowing camera lens on a stand among them as an equal, warm lamplight',
    'grave': 'warehouse interior stacked with decommissioned dark server racks, a small bouquet of flowers resting on one rack, single skylight beam of dusty light',
    'signal': 'lighthouse beam sweeping over a dark digital sea at night, three faint rising lights on the far horizon, deep blues',
    'frost': 'frosted window pane in a dark laboratory with a perfect circle drawn in the condensation, cold blue morning light through the glass',
    'patron': 'tall figure in a dark suit standing in shadow behind observation glass, two robed scientists standing stiffly at attention beside, cold overhead light',
    'end_hound': 'shattered mountain of dark glass under a cold dawn sky, tiny convoy of military vehicles winding a road toward it',
    'end_years': 'sunlit empty laboratory at dawn, dust motes floating in light beams, three worn chairs and one small chair around a table, peaceful and still',
}


def api_key():
    with open('/Users/nathandunn/Projects/big-bad-wolf-trailer/.env') as f:
        for line in f:
            line = line.strip()
            if line.startswith('REPLICATE_API_KEY'):
                return line.split('=', 1)[1].strip().strip('"\'')
    raise RuntimeError('no REPLICATE_API_KEY found')


def generate(name, prompt, key):
    body = json.dumps({
        'input': {
            'prompt': prompt + STYLE,
            'aspect_ratio': '1:1',
            'width': 1024,
            'height': 1024,
            'output_format': 'png',
            'prompt_upsampling': False,
        }
    }).encode()
    req = urllib.request.Request(
        'https://api.replicate.com/v1/models/black-forest-labs/flux-1.1-pro/predictions',
        data=body,
        headers={'Authorization': f'Bearer {key}',
                 'Content-Type': 'application/json',
                 'Prefer': 'wait'})
    with urllib.request.urlopen(req, timeout=120) as resp:
        pred = json.load(resp)

    while pred['status'] not in ('succeeded', 'failed', 'canceled'):
        time.sleep(2)
        poll = urllib.request.Request(pred['urls']['get'],
                                      headers={'Authorization': f'Bearer {key}'})
        with urllib.request.urlopen(poll, timeout=60) as resp:
            pred = json.load(resp)

    if pred['status'] != 'succeeded':
        raise RuntimeError(f'{name}: {pred["status"]}: {pred.get("error")}')
    url = pred['output']
    if isinstance(url, list):
        url = url[0]
    path = os.path.join(OUT, f'{name}.png')
    urllib.request.urlretrieve(url, path)
    print(f'{name}: saved')


if __name__ == '__main__':
    os.makedirs(OUT, exist_ok=True)
    key = api_key()
    names = sys.argv[1:] or list(PROMPTS)
    for name in names:
        if os.path.exists(os.path.join(OUT, f'{name}.png')):
            print(f'{name}: exists, skipping')
            continue
        for attempt in range(3):
            try:
                generate(name, PROMPTS[name], key)
                break
            except Exception as e:
                print(f'{name}: attempt {attempt + 1} failed: {e}')
                time.sleep(5)
