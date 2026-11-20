# Literal ordered boxes under Linux GTSTD

Original MIT partial evaluation, not a general screen or terminal emulator.
The whole input must contain a single parameter-free Main, consisting only
of literal DispBox calls and RETURN. Boxes must occupy disjoint strictly
increasing rows. Mixing output, variables, branches, loops, functions or
methods is rejected before code generation.

Coordinates must be integer literals, top < bottom, left < right, within
rows 0..23 and columns 0..78. Last physical row/column and clipping are outside
this increment. Borders are default, integer1/2, or eight/nine counted bytes
made from literal strings, concatenation, literal Chr byte calls and
hb_UTF8ToStrBox of the measured CP437 single/double/mixed box glyphs and ASCII.
Optional literal color is evaluated but has no byte effect under GTSTD.
Explicit borders reject all spaces, controls, DEL and bytes outside printable
ASCII33..126 or the twenty measured CP437 box bytes. Even a ninth-byte space
is rejected; omit that byte to select the default interior-space fill. Other
conversion glyphs are rejected.

Within that closed program, output is partially evaluated from box geometry,
border/fill and vertical cursor movement, then emitted as literal byte data
and stdout syscalls. No source-specific expected output or Harbour code is
embedded. The original tests/box.prg hash is checked against the pinned
inventory and its stdout/stderr/rc compared with a fresh external oracle.
Mixed QOut output can expose preserved screen contents and is deliberately
not modeled or silently accepted. Other backends and LLVM are rejected.

```
python3 tests/box-gtstd/check.py --compiler /absolute/hbc \
 --hbmk2 /absolute/hbmk2 --harbour-core /absolute/core --output /new/output
```
