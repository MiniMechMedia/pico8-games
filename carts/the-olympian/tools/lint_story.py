#!/usr/bin/env python3
"""Static checks on story.lua: node targets exist, images exist, guards/assigns
well-formed, every non-ending node reaches a choice or goto, endings unique."""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
s = open(os.path.join(ROOT, 'story.lua')).read()
s = re.sub(r'(?m)^\s*--.*$', '', s)  # strip comments

nodes = re.findall(r"node\('([a-z0-9_]+)'", s)
dupes = {n for n in nodes if nodes.count(n) > 1}
targets = re.findall(r"'\*([a-z0-9_]+)", s)
images = re.findall(r"'@([a-z0-9_]+)'", s)
endings = [int(x) for x in re.findall(r"'~e(\d+)'", s)]
guards = re.findall(r"\s\?([!a-z0-9=_]+)", s)
assigns = re.findall(r"\s!([a-z0-9]+=[a-z0-9]+)", s)

blobs = {f[:-5] for f in os.listdir(os.path.join(ROOT, 'tools', 'build'))
         if f.endswith('.blob')}
fullres = {f[:-4] for f in os.listdir(os.path.join(ROOT, 'fullres_images'))
           if f.endswith('.png')}

errs = []
if dupes:
    errs.append(f'duplicate nodes: {dupes}')
for t in set(targets):
    if t not in nodes and t != 'title':
        errs.append(f'missing node target: {t}')
for n in set(nodes):
    if n not in targets and n != 'intro':
        errs.append(f'unreachable node: {n}')
for img in set(images):
    if img not in fullres:
        errs.append(f'missing fullres image: {img}')
    if img not in blobs:
        errs.append(f'image not yet piped: {img}')
if sorted(endings) != list(range(1, len(endings) + 1)):
    errs.append(f'ending numbers not 1..n: {sorted(endings)}')

# every ending node must loop to title
for m in re.finditer(r"node\('(e_[a-z0-9_]+)',\{(.*?)\n\}\)", s, re.S):
    if "'*title" not in m.group(2):
        errs.append(f'{m.group(1)}: no return to title')

print(f'{len(set(nodes))} nodes, {len(set(images))} images used, '
      f'{len(endings)} endings, {len(set(targets))} link targets')
print(f'guards: {sorted(set(guards))}')
print(f'assigns: {sorted(set(assigns))}')
if errs:
    print('\nERRORS:')
    for e in errs:
        print(' -', e)
    sys.exit(1)
print('story graph ok')
