# Dynamic integer FOR STEP

Own MIT increment above49307044. STEP is now an AST expression, admitted as
an integer variable or zero-argument integer function call on ordinary Linux
only. Constant folded nonzero integer STEP retains its existing path.
Dynamic expressions with arguments, arithmetic, sequence effects, floats,
Dyn and other target/thread/macro/shared-capture profiles stay rejected.
Zero-valued dynamic STEP follows Harbour's nonnegative comparison and zero
increment. It may not terminate, just like the measured oracle. Tests use
explicit EXIT, never an unbounded zero-step loop.

Fresh oracle demonstrated START once, then TO and STEP at each comparison,
STEP again at NEXT before advancing. LOOP reaches that NEXT evaluation;
EXIT skips it. Current value and sign are not cached. STEP now participates
in AST visitors, type pinning, move checks, borrow/escape/read-only proofs,
trace analysis and block collection. LLVM explicitly rejects dynamic STEP;
constant STEP retains native/traced/untraced exact execution controls.
Integer overflow retains the pre-existing stop-on-overflow restriction,
not a new claim about Harbour arbitrary numeric continuation.

Gate111:10positive sources x5modes=50exact stdout/stderr/rc executions,
10strict final zero balances,40profile rejections,11named unsupported forms.
Covers mutable/counter STEP, positive/negative/changing sign, zero, skipped
body, nested loops, LOOP/EXIT, exact evaluation order, stateful step call,
exception from step call, integer parameter, and promoted manifest t44.
Constant gate54 separately passes with its former call/variable negatives
now positive on Linux. Oracle git694428e1c12f726675b19324d62167fa77d68185;
hbmk2SHA2562fb1503a38760b9e94617fd6243ec0a8f65c6a84e079fed0efc47d66633c40ae.
CompilerSHA25609bae3e732adfced28893eade85532d7762bc13ba0e2f94b1a7da7de22b5b5aa.

Current-compiler regression fresh:19prior suites, each compiler SHA checked
(including enum string116 and mandatory original wrapper190exact/balance
plus2known DELTA2 debts, not lifetime passes). Rust106,LLVM21exact,
Linux manifest1182exact stdout/stderr/status. Manifest t44 changes from old
negative to oracle-grounded positive. Remaining621negative cases identical
to fresh published15607b62 on Linux/Windows. PE1915PASS/23known/0FAIL,
emission only; t44's new non-Linux profile rejection is explicit debt.
Original census1041still58admitted, one diagnostic-only change for for.prg.
It still rejects Eval(block) STEP; it is not closed or newly admitted.
No original closure, performance claim, RC/object or numeric-array expansion.
ASort external original corpus still unavailable; not full historical replay.

Initial gate attempts found fixture LAST name conflicts with Harbour's
abbreviation of LASTREC, and constant gate assumed other-target dynamic
support. Fixed test name and explicit rejection expectation, retained failed
logs, never counted them PASS. Census comparison initially asserted all
hashes unchanged; raw report records the one expected named limit change.
No supplied implementation/cambio.diff used. Julio Ponce MIT programs remain
credited specifications only. New commit, no push/publication/workflows or
rebase. Package excludes binaries/objects/disposable assembly.

python tests/dynamic-for-step/check.py --compiler target/release/hbc --hbmk2 /path/hbmk2 --spec-root /path/harbour --output /new/path
