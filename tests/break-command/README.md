# BREAK command spelling

Own MIT increment on a3b6511004dc9ce8e1516ddd95b64da2827ee94e.
No push, publication or workflows. Harbour programs and outputs are
specifications only. No supplied implementation or cambio.diff was used.
Julio Ponce's MIT ASort examples remain credited regression sources.

The parser now lowers bare BREAK to the existing Break(NIL) statement,
and BREAK expression to the existing Break(value) path. No new runtime
helper or ownership policy. Parenthesized Break(value) keeps its existing
parser. Empty Break() stays rejected, matching the fresh Harbour syntax
probe. The old catch/value limitations and sequence-without-RECOVER
restriction are unchanged.

Gate19: two own fixtures x5Linux modes=10 exact fresh Harbour executions,
2 strict final zero balances,1 empty-call rejection and6 other-target
emission checks.117rounds cover NIL,integer,owned string,temporary string,
cross-function unwind,nested catches,catch replacement and bare RECOVER.
Other target execution is not claimed. The owned fixture initially hit
the existing conservative moved-in-loop rejection; its owner is now
explicitly reinitialized before NEXT. That failed attempt is preserved.

92 prior native suites complete,including constant-for-step and ASort2
mandatory58. LLVM fresh gate21 also passes. Rust104,Linux1177goldens exact,
PE1912PASS22known0FAIL emission-only,negative622 same16 combined mismatches.
Census57/1041,zero new admissions. begin.prg advances from bare BREAK
line32 to sequence-without-RECOVER line39. big5_gen/uc16_gen pass their
bare BREAK parser sites,then reach the existing AFill expression gap
(lines55/31). Earlier diagnostics were later parser failures,so the new
error line numbers can decrease. No newly closed original or speed claim.
Known inhprob/classch DELTA2 debt remains unchanged.

A full-disk oracle-link failure interrupted13suites in the initial batch.
These are retained as incomplete,not PASS. After deleting only disposable
regression assembly/objects/IR,the13suites were rerun successfully and the
remaining batches completed. Final batch counts35+30+27=92 all rc0.

    python tests/break-command/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/break-command-gate
