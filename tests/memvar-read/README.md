# Explicit scalar MEMVAR reads

Own MIT increment on a9983044a6fc73f5e26d4b1b15013bc888549d98.
No push,publication or workflows. Harbour outputs are specifications only.
No supplied implementation or cambio.diff. Julio Ponce's MIT ASort
examples remain credited regression specifications.

M->identifier and MEMVAR->identifier now read through the existing scalar
MEMVAR resolver,not local-variable lookup. A same-named LOCAL therefore
does not shadow the explicit MEMVAR read. A compiler-only call marker
carries the literal name; the existing resolver returns an owned tagged
snapshot. PRIVATE scope restoration and PUBLIC persistence are unchanged.
Only ordinary Linux native is admitted. This activates the existing
MEMVAR context,so its existing date/shared-array/other restrictions still
apply. No new runtime helper or change to MEMVAR storage/RC policy.

Forced stores,indexed reads,dynamic names,other target profiles and LLVM
remain rejected. RECOVER into a MEMVAR is not implemented. Missing-name
error text/default-handler parity is not claimed.

Gate30:3 own sources x5Linux modes=15 exact fresh Harbour executions,
3strict final zero balances,3negative checks,9profile rejections.
Covers LOCAL/PUBLIC/PRIVATE homonyms,private restoration,case-insensitive
names,117owned-string snapshot/replacement rounds,integer/logical/NIL/
float values and independent lookup snapshots after replacement.

94prior native suites complete(35+30+29),ASort2mandatory58,
LLVMfresh21,Rust104,Linux1177goldens exact,PE1912PASS22known0FAIL emission,
negative622same16combined. Census57/1041,no admissions. Only begin.prg
diagnostic changes: M-> parsing is passed,but function break1 lacks a
closing RETURN supported by this parser. It does not close. No performance
claim. Known inhprob/classch object-lifetime DELTA2 remains open.

    python tests/memvar-read/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/memvar-read-gate
