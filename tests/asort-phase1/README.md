# ASort phase 1: flat local literals and bounded ranges

Own MIT on main adee538e. Julio Ponce's MIT ASort package contributes
programs a01/a02 and Harbour output specifications; no implementation or
diff was copied. cambio.diff was not opened. Checkers read external specs
from --spec-root, not vendored sources. No workflow changes,push or publish.

Entry: an integer-only LOCAL array literal used by direct ASort with up to
three arguments selects existing ordinary-Linux A2 storage. Sibling constant
text literals use that same storage. A program with only text literals
keeps the old path. Callbacks,mixed arrays,float arrays,constructors,
received parameters and computed literals are outside this increment.
The existing non-A2 ASort paths are unchanged.

Shared ASort accepts one to three arguments with a named shared root and
integer or literal NIL start/count. It returns that root's tag16 identity.
Runtime checks the entire array before moving any cells: only all integer
or all owned text cells. Mixed/wrong families get the existing named type
error. Stable adjacent-cell sorting uses a private full-length binary text
comparison,not the asymmetric ordinary expression comparison. No callback
ordering or comparison-sequence claim. No ownership cloning during sort:
whole cells swap in place,keeping exclusive text payload ownership.

Start NIL/0 defaults to1; negative/beyond-length is a no-op. Count NIL,
nonpositive or beyond the remaining length means to the end. Clamp before
addition avoids overflow for the largest positive integer. These rules
and prefix/empty text sorting are measured against fresh Harbour,not merely
inferred from supplied logs. The first attempted expression-comparison
reuse ordered empty text wrongly; it was fixed,not counted as passing.

Gate67: six own programs plus a01/a02,eight sources x4Linux modes=32 exact
executions,eight strict balances,24 non-Linux profile rejections,3limits.
Modes:native,external assembler,--no-vas-arrays,--no-escape-analysis.
Own checks include aliases,returned identity,NIL/default/negative/huge
ranges,43x137 owned-text lifetimes,and137 later argument exceptions.
Strict balance requires exact stdout,rc0,empty stderr;missing DELTA alone
never means success. Len(ASort(...)) remains a separate static-check gap.

    python tests/asort-phase1/check.py --compiler target/release/hbc --hbmk2 /path/to/harbour/bin/linux/gcc/hbmk2 --spec-root /path/to/julio/programas --output /tmp/asort-check

Current main adee538e rejects all16 supplied ASort programs;head closes
only a01/a02 here. Of15 freshly executable Harbour sources,the13minimals
match Julio's supplied bytes. e18 has GTSTD long-line wrapping differences;
e19 has GTSTD trailing-space trimming differences. These are preserved,
not normalized into exact claims. e20 is not a fresh Harbour differential
because hb_memcheck is not linked by the standard oracle. No fake adapter.

Regressions:timestamp1..9,B1=152,B2=115,A1/A2,cycle59,nested51,Rust99.
Linux1177:1176 exact and inherited ctod_order_epoch output failure,
reproduced identical with main adee538e. Negatives622 unchanged including
13known mismatches. PE emission only1912PASS,22known,0FAIL. Census48/1041
admitted in both current main and head,no admission changes in this phase.
No native Windows/Mac runtime extension. Reduced bundle/patch,LEEME,
manifest,compiler SHA and raw text logs,no binary/object/disposable assembly.
