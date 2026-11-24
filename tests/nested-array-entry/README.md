# Tagged nested local array entry, cumulative with explicit cycles

Own MIT on main422956e42e9bb8c18c873beb3072ff2e601e2735.
Unmodified harbour/core tests/array.prg and tests/strdelim.prg and fresh
Harbour outputs are specifications only. No implementation copied.
Original sources are not vendored; checkers take --harbour-root and record
source SHA. No workflow/DBF changes, push or publication in this diff.

This cumulative package contains two entry fixes to the existing A2 shared
heap: constant local arrays stored in their own cell, and constant nested
local arrays with noninteger leaves and an explicit two-index store. The
latter closes strdelim's {{NIL}} then a[1][1]:="Hello" shape. Ordinary
integer-only nested arrays and ordinary unrelated literals keep their old
representation. Selection is syntactic and conservative: dead stores can
select A2 and expose its named restrictions. Existing A2 ownership,
collector and restrictions remain in charge. No new collector or backend.

Both originals pass fresh Harbour comparison in four Linux modes with
strict final balance0. Current main admits46/1041; this package48/1041.
Only new admissions:array.prg and strdelim.prg. No losses. Admission is not
runtime equivalence for the other46; remaining993 reject compilation.

Cycle gate59:28 exact,7balances,21profile rejections,3limits.
Nested gate51:24 exact,6balances,18profile rejections,3limits. Tests cover
NIL/text retyping,alias/rebinding,owned text,Date/float,117 overwrites per
call,37 repeated calls,and117 exceptions during index evaluation.
Len/ValType/DToS of certain deep indexes are still rejected, as found in
exploration, not claimed fixed. Hashes,blocks and Array() remain A2 limits.
A missing DELTA alone never means success: exact stdout,rc0,empty stderr
are required for a successful strict final balance.

    python tests/nested-array-entry/check.py --compiler target/release/hbc --hbmk2 /path/to/harbour/bin/linux/gcc/hbmk2 --harbour-root /path/to/harbour --output /tmp/nested-check

Regressions on integrated compiler:timestamp1..9,B1=152,B2=115,A1/A2,
cycle59,Rust99. Linux1177:1176 exact plus the inherited ctod_order_epoch
output failure, reproduced identically with current main422956e4.
Negatives622 unchanged including13known mismatches. PE emission only:
1912PASS,22known,0FAIL. No native Windows/Mac runtime claim. e17 remains
internal assertions/pending0, not fresh Harbour:standard oracle does not
link hb_memcheck, and no false substitute is used.

The earlier delivered cycle commit3b8be9d2 is preserved. This review branch
contains its reapplied commit77aca8db on new main, followed by the nested
entry increment. The old package is superseded by this cumulative package.
No DBF or CI changes attributed to this work. Reduced bundle,format-patch,
LEEME,SHA manifest,compiler SHA and raw text evidence only;no binary/object
or disposable assembly.
