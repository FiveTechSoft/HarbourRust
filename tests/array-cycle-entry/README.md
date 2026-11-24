# Constant local array cycle entry

Own MIT implementation on c9ebc8b8a7ab8952a51fb85c17a85f9006ac605f.
The unmodified harbour/core tests/array.prg and fresh Harbour outputs are
specifications only. No implementation copied. Original source is not
vendored; the checker takes --harbour-root and records its source SHA.
No workflow changes, push, publication or history rewriting.

A constant local array with an explicit single-index self-store a[i]:=a
now selects the existing ordinary-Linux shared-array heap. This closes an
identity/cycle entry hole: the old fixed-cell representation cannot hold
its own array. It does not switch ordinary array literals globally.
Existing A2 literal discovery, alias propagation, cell operations, collector
and restrictions remain in charge. The scan is syntactic and conservative,
so a dead self-store can also select A2 and expose its named restrictions.
No new collector, container kind or backend is introduced.

Original tests/array.prg: exact stdout/rc0/empty stderr against fresh Harbour
in four Linux modes, strict final balance0. Censo1041: base46 admitted,
head47; the only admission change is tests/array.prg, no losses. Admission
is not a runtime compatibility count. The remaining994 reject compilation.

Gate59: six own programs plus the original,28 exact executions in native,
external assembler,--no-vas-arrays,--no-escape-analysis; seven strict final
balances;21 non-Linux named rejections;three A2 limits. Own tests cover
breaking the cycle, leaving a live cycle, alias/rebinding, owned text,
317 repeated lifetimes,157 exceptions and conditional stores. Hashes,
blocks and Array() still reject in this selected profile. Missing DELTA
alone is never success: rc0,empty stderr and exact stdout are required.

    python tests/array-cycle-entry/check.py --compiler target/release/hbc --hbmk2 /path/to/harbour/bin/linux/gcc/hbmk2 --harbour-root /path/to/harbour --output /tmp/cycle-check

Regressions: timestamp1..9;B1=152;B2=115;A1/A2;Rust99.
Linux manifest1177:1176 exact,one inherited ctod_order_epoch output failure,
reproduced identically with the base compiler. No all-green claim.
Negatives622 identical to phase9 including13known mismatches. PE emission
only1912PASS,22known,0FAIL. No Windows/Mac runtime claim.
Reduced package: bundle,format-patch,LEEME,compiler SHA,manifest and raw
text logs. No executable,object or disposable assembly. e17 remains an
internal assertion/pending0 check,not a fresh Harbour differential: its
hb_memcheck is not linked by the standard oracle, and is not faked here.
