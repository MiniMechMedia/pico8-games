"""Image pipeline: fullres png -> 128x128 pico-8 quantized -> px9 compressed blob.

Usage:
    python imgpipe.py ../fullres_images/foo.png [more.png ...]
    python imgpipe.py --all

Outputs (relative to this tools/ dir):
    ../processed_images/<name>.png   preview of quantized image
    build/<name>.blob                raw px9-compressed bytes
    build/<name>.pal                 text file: comma-separated pico color ids (0-31)
"""
import os
import subprocess
import sys
from glob import glob

from PIL import Image

TOOLS = os.path.dirname(os.path.abspath(__file__))
PICO8 = '/Applications/PICO-8.app/Contents/MacOS/pico8'
MAX_BLOB = 10000  # blobs reload directly to upper mem 0x8000; cap is cart capacity
# counts of non-reserved colors; slots 0 (black) and 7 (white) are always reserved
# so text drawn over images stays readable
COLOR_LADDER = [14, 12, 10, 8, 6]
FREE_SLOTS = [1, 2, 3, 4, 5, 6, 8, 9, 10, 11, 12, 13, 14, 15]

PICO_PALETTE_HEX = '''
#000000 #1d2b53 #7e2553 #008751 #ab5236 #5f574f #c2c3c7 #fff1e8
#ff004d #ffa300 #ffec27 #00e436 #29adff #83769c #ff77a8 #ffccaa
#291814 #111d35 #422136 #125359 #742f29 #49333b #a28879 #f3ef7d
#be1250 #ff6c24 #a8e72e #00b543 #065ab5 #754665 #ff6e59 #ff9d81
'''.split()
PICO_RGB = [(int(x[1:3], 16), int(x[3:5], 16), int(x[5:7], 16)) for x in PICO_PALETTE_HEX]


def make_pal_image(rgb_list):
    p = Image.new('P', (1, 1))
    flat = []
    for c in rgb_list:
        flat.extend(c)
    # pad to 256 entries with the first color
    while len(flat) < 768:
        flat.extend(rgb_list[0])
    p.putpalette(flat)
    return p


def quantize(img128, n_colors):
    """Return (indices: 16384 slot values 0-15, palmap: 16 pico color ids per slot).

    Slot 0 is always pico black (0), slot 7 always pico white (7); the image's
    other colors occupy the remaining 14 slots. Black and white stay available
    as quantization targets so dark/bright pixels map to the reserved slots.
    """
    q32 = img128.quantize(palette=make_pal_image(PICO_RGB), dither=0)
    hist = {}
    for v in q32.getdata():
        hist[v] = hist.get(v, 0) + 1
    ranked = sorted(hist, key=hist.get, reverse=True)
    others = [c for c in ranked if c not in (0, 7)][:n_colors]
    # quantization palette: index 0=black, 1=white, 2.. = image colors
    sub_rgb = [PICO_RGB[0], PICO_RGB[7]] + [PICO_RGB[c] for c in others]
    qn = img128.quantize(palette=make_pal_image(sub_rgb), dither=0)
    idx_to_slot = {0: 0, 1: 7}
    for j in range(len(others)):
        idx_to_slot[j + 2] = FREE_SLOTS[j]
    indices = [idx_to_slot[min(v, len(sub_rgb) - 1)] for v in qn.getdata()]
    palmap = [0] * 16
    palmap[7] = 7
    for j, c in enumerate(others):
        palmap[FREE_SLOTS[j]] = c
    return indices, palmap


def compress(indices, name):
    """Run px9 job cart in pico8, return blob bytes."""
    with open(os.path.join(TOOLS, 'px9_template.p8')) as f:
        template = f.read()
    lines = []
    for y in range(128):
        row = indices[y * 128:(y + 1) * 128]
        lines.append(''.join('0123456789abcdef'[v] for v in row))
    job_path = os.path.join(TOOLS, 'px9_job.p8')
    with open(job_path, 'w') as f:
        f.write(template.rstrip() + '\n' + '\n'.join(lines) + '\n')
    out = subprocess.run([PICO8, '-x', job_path], capture_output=True, text=True,
                         timeout=120, cwd=TOOLS)
    stdout = out.stdout
    if '!!blobstart' not in stdout:
        raise RuntimeError(f'px9 job failed for {name}:\n{stdout}\n{out.stderr}')
    body = stdout.split('!!blobstart')[1]
    header, rest = body.split('\n', 1)
    clen = int(header.strip())
    hexstr = rest.split('!!blobend')[0].replace('\n', '').strip()
    blob = bytes.fromhex(hexstr)
    assert len(blob) == clen, f'{name}: expected {clen} bytes, got {len(blob)}'
    return blob


def process(img_path):
    name = os.path.splitext(os.path.basename(img_path))[0]
    img = Image.open(img_path).convert('RGB')
    img128 = img.resize((128, 128), Image.LANCZOS)

    for n_colors in COLOR_LADDER:
        indices, palmap = quantize(img128, n_colors)
        blob = compress(indices, name)
        print(f'{name}: {n_colors} colors -> {len(blob)} bytes')
        if len(blob) <= MAX_BLOB:
            break
    else:
        raise RuntimeError(f'{name}: could not fit under {MAX_BLOB} bytes')

    os.makedirs(os.path.join(TOOLS, 'build'), exist_ok=True)
    os.makedirs(os.path.join(TOOLS, '..', 'processed_images'), exist_ok=True)

    # preview
    preview = Image.new('RGB', (128, 128))
    preview.putdata([PICO_RGB[palmap[v]] for v in indices])
    preview.resize((512, 512), Image.NEAREST).save(
        os.path.join(TOOLS, '..', 'processed_images', f'{name}.png'))

    with open(os.path.join(TOOLS, 'build', f'{name}.blob'), 'wb') as f:
        f.write(blob)
    with open(os.path.join(TOOLS, 'build', f'{name}.pal'), 'w') as f:
        f.write(','.join(str(c) for c in palmap))
    return blob, palmap


if __name__ == '__main__':
    if sys.argv[1] == '--all':
        paths = sorted(glob(os.path.join(TOOLS, '..', 'fullres_images', '*.png')))
    else:
        paths = sys.argv[1:]
    for p in paths:
        process(p)
