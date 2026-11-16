#!/usr/bin/env python3
# Generate the Windows (PE/COFF) hrobj runtime blobs from the validated
# Linux ones. The blob's instruction stream is target-independent: the
# hrobj runtime is freestanding (no OS calls) and follows hbc's internal
# SysV convention on BOTH targets (the Win64 convention only applies at
# the kernel32 boundary and the C-blob wrappers, never here). Only the
# ELF-only assembler DIRECTIVES differ, and all of them are metadata the
# COFF object format neither needs nor accepts:
#   .type name,@function / .size name,.-name  - ELF symbol metadata
#   .hidden name                              - ELF visibility
#   .section .note.GNU-stack / .note.gnu.property (blob tail)
#                                             - ELF marker sections
# Dropping them does not change one emitted byte of code or data.
#
# Derivation ledger (this header IS the ledger):
#   input  src/hrobj_blob.s      -> output src/hrobj_blob_win.s
#   input  src/hrobj_blob_mt.s   -> output src/hrobj_blob_mt_win.s
#   transform: truncate at the first `.section .note` directive; drop
#   every .type/.size/.hidden line; prepend a provenance comment with
#   the input sha256. Rerun after ANY change to a Linux blob; the
#   Windows blob is never edited by hand.
# Recorded inputs at introduction (16Nov2026), PRE strlen-header fix
# (the fix landed in the same commit; see the commit message):
#   hrobj_blob.s    sha256 0b343009c30b9ebac3e6f05f6541fd646236a37631e00017841ea6e31650c7e7
#   hrobj_blob_mt.s sha256 aa07ed9b44e03805c7014bdf3dc0be5fc0b7173a17c9f1517253d107c330194c
# Current inputs (post-fix; also embedded in the generated files):
#   hrobj_blob.s    sha256 4546aa4258254af29ab3dfe7461f0366cfd1f8a00c5cbc547e3c9e18b6972284
#   hrobj_blob_mt.s sha256 3fbf93b13d5771e49fef07452c41fe3f70ec4c89c3b8069193fe4ba10a43eeb6
import hashlib, pathlib, re, sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
PAIRS = [("src/hrobj_blob.s", "src/hrobj_blob_win.s"),
         ("src/hrobj_blob_mt.s", "src/hrobj_blob_mt_win.s")]
DROP = re.compile(r"^\s*\.(type|size|hidden)\s")

for src, dst in PAIRS:
    data = (ROOT / src).read_text()
    cut = data.find("\t.section\t.note.GNU-stack")
    if cut < 0:
        sys.exit(f"{src}: .note.GNU-stack marker not found - blob layout changed, regenerate manually")
    body = data[:cut]
    if ".note" in body:
        sys.exit(f"{src}: unexpected earlier .note section - refusing to guess")
    kept, dropped = [], 0
    for line in body.splitlines(keepends=True):
        if DROP.match(line):
            dropped += 1
        else:
            kept.append(line)
    if dropped != 9:
        sys.exit(f"{src}: expected 9 ELF-only directive lines (3x .type/.size/.hidden), found {dropped}")
    body = "".join(kept)
    sha = hashlib.sha256(data.encode()).hexdigest()
    header = (f"# Windows (PE/COFF) hrobj runtime blob - GENERATED, do not edit.\n"
              f"# Derived from {src} (sha256 {sha}) by\n"
              f"# tests/generate_hrobj_windows_blob.py: instruction stream copied\n"
              f"# verbatim; ELF-only directives dropped (.type/.size/.hidden,\n"
              f"# trailing .note marker sections) - metadata with no emitted\n"
              f"# bytes. See the generator header for the derivation ledger.\n"
              f"# Regenerate after any change to {src}.\n")
    (ROOT / dst).write_text(header + body)
    print(f"wrote {dst} ({len(body.splitlines())} body lines, input sha256 {sha})")
