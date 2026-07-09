#!/usr/bin/env python3
"""Assemble mech-fighting.p8 from main.lua + gfx.txt + sfx.txt; count tokens."""
import re
import sys

import os
BUILD = os.path.dirname(os.path.abspath(__file__))
CART = "/Users/nathandunn/Projects/pico8-games/carts/mech-fighting/mech-fighting.p8"


def count_tokens(src):
    """Approximate PICO-8 token count (conservative)."""
    src = re.sub(r"--\[\[.*?\]\]", "", src, flags=re.S)
    src = re.sub(r"--[^\n]*", "", src)
    toks = re.findall(
        r'"[^"]*"'            # strings
        r"|'[^']*'"
        r"|0b[01.]+|0x[0-9a-fA-F.]+|\d+\.?\d*|\.\d+"  # numbers
        r"|[A-Za-z_]\w*"      # idents/keywords
        r"|!=|==|<=|>=|~=|\.\.|[+\-*/\\%^#<>=(){}\[\],.:;?]",
        src)
    n = 0
    for t in toks:
        if t in ("end", "local", ",", ".", ";", ":", ")", "}", "]"):
            continue
        n += 1
    return n


def main():
    lua = open(f"{BUILD}/main.lua").read()
    gfx = open(f"{BUILD}/gfx.txt").read()
    sfx = open(f"{BUILD}/sfx.txt").read()
    n = count_tokens(lua)
    print(f"approx tokens: {n} / 8192")
    if n > 8192:
        print("OVER BUDGET")
        sys.exit(1)
    try:
        label = open(f"{BUILD}/label.txt").read()
    except FileNotFoundError:
        label = ""
    cart = ("pico-8 cartridge // http://www.pico-8.com\nversion 43\n"
            "__lua__\n" + lua.rstrip("\n") + "\n" + gfx + label + sfx)
    open(CART, "w").write(cart)
    print(f"wrote {CART}")


if __name__ == "__main__":
    main()
