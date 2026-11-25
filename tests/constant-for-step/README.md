# Constant integer STEP and live FOR TO evaluation

Own MIT increment on ebbf765da4996c33978aab3ecc9a602de2dbe48a.
No workflows, push or publication. Fresh Harbour programs and outputs are
specifications only. No supplied implementation or cambio.diff was used.
Julio Ponce's MIT ASort examples remain credited regression specifications.

STEP now goes through the existing expression parser and is admitted only
when its result is a nonzero Int. This includes parentheses, unary plus,
integer +,-,*, exact division and integer modulus that already fold.
Dynamic values, calls, sequence expressions with effects, float results,
power, overflow, zero and zero-divisor expressions stay rejected. There
is no dynamic-step lowering or numeric-cell/RC-policy change.

The new differential exposed an older semantic defect: native FOR cached
TO once. Harbour evaluates START once, then TO before each comparison,
including the final failed comparison. TO emission now lives at the
condition label. LOOP rechecks TO and EXIT does not. The checker rejects
TO expressions that consume an owned local, because repeating them would
reuse a moved owner. Its snapshot must precede type_expr, which can mark
moves itself. A named negative test enforces this guard.

The old t146 golden encoded the caching defect. A fresh, intact Harbour
run of t146 is preserved and supplies the corrected Linux expectation.
Windows expectation is the same bytes with CRLF, an explicit formatting
adaptation, NOT evidence of Windows execution. Other native target
emission succeeds; PE/Mach-O runtime behavior is not claimed. LLVM
backends were not independently executed for this increment.

Gate38: three own fixtures x five Linux modes = 15 exact fresh Harbour
executions, three strict final zero balances, eleven named rejections,
and nine other-target emission checks. Covers folded step forms, both
directions, nested loops, LOOP/EXIT, final counter values, live mutable
TO bounds, counter-dependent TO, start/end call order, repeated TO calls,
and the skipped-body comparison. The first experiment failed because of
fixture counter types; the next exposed the true TO mismatch. An initial
owned-TO guard placed its snapshot too late and failed its own negative
test. These failed attempts are retained separately and never count PASS.

Final compiler: 91 prior suites complete, including ASort2 mandatory
58=42 own+16 Julio originals. Rust104. Linux1177 exact stdout goldens
using the one source-grounded t146 correction. PE1912 PASS,22 known,0 FAIL,
emission only. Negative622 retain16 combined mismatches (Linux7/Windows9).
Census57/1041 with no new admissions. Only big5_gen/uc16_gen diagnostics
advance past folded STEP to later unsupported statements. No original
newly closes and no speed claim is made. Original calls retains40 exact,
6 zero balances and2 known DELTA2 object-lifetime debts.

Run:

    python tests/constant-for-step/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/for-step-gate

Follow-up dynamic-for-step promotes historical limit-call/limit-dynamic to
fresh differential controls on ordinary Linux. Other targets still reject
these two sources. Current gate54 comprises25exact,5zero,9other-target
emissions,6dynamic-profile rejections and9remaining named limits.
