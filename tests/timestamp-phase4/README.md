# Timestamp phase 4: timestamp comparison

Own MIT implementation on 63bf10eaa8bbebd63902bbbc071128fdc94e4588.
Julio Ponce's MIT programs and Harbour outputs are specifications only.
No implementation or diff from Julio or Harbour was copied. No push,
publication or workflow changes are part of this delivery.

## Scope

Ordinary Linux timestamp-vs-timestamp =, ==, !=, <, >, <= and >= use the
non-owning tag17 payload, Julian day then milliseconds, ordered unsigned.
Timestamp equality against NIL is false; inequality against NIL is true.
The existing Dyn scalar comparison paths remain for non-timestamp values.
Function parameters, array reads and direct timestamp producers are covered.

Mixed Date/timestamp comparison is NOT included. Harbour's = and ordering
ignore time for that combination while == does not; exploratory probes
confirmed these different coercions. Runtime mixed kinds remain catchable
type errors, not a claim of Harbour equivalence. Known timestamp comparisons
with static non-Dyn operands are rejected before code generation. Two Dyn
cells are still checked at runtime. Timestamp arithmetic remains rejected.
No generic Empty(Dyn), hash/DATA/FOR EACH or PE/Mac/thread/macro extension.
e16 remains unresolved. This package closes original t05 only.

## Verification

    python tests/timestamp-phase4/check.py --compiler target/release/hbc --hbmk2 /path/to/harbour/bin/linux/gcc/hbmk2 --output /tmp/ts4-check

Run from the repository root; output directory must not exist. Gate 50 rows:
20 fresh Harbour exact executions (five own programs in four modes), four
own runtime-error executions, six strict final balances, 18 unsupported
profile rejections and two named limits. The runtime case checks 404 catches
and ownership, not Harbour Error-object or mixed-kind equivalence.

Original t05 runs unmodified against fresh Harbour 3.2.1dev r2610242111 in
four modes and has strict final DELTA=0. Source hash and raw logs included.
The phase1 checker now executes its two former comparison-limit fixtures:
42 exact executions plus two streams, 14 balances, four remaining named
limits. Those old fixtures were not silently dropped to keep a green gate.

Other regressions: timestamp2 61, timestamp3 51, B2 115, B1 152, A1/A2 pass;
Linux1174 exact outputs; Rust99; PE emission/diagnostics1909 PASS,22 known,
0 FAIL. Negatives622 identical to phase3, including13 known mismatches.
No native PE/Mac runtime claim. Final balance requires exact stdout, rc0
and empty stderr; missing DELTA alone never means success.

The reduced package contains bundle/format-patch, LEEME/attribution, SHA
manifest, compiler SHA and raw text evidence, no executable/object or
disposable assembly. Source history is new commits only.
