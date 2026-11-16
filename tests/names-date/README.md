# Names and Date probes on 7b746e2a

## Final source contract

The lexical-name implementation and Date builtin consumer fix come from upstream 7b746e2a. This candidate preserves upstream DBF, Dyn print and year-zero changes. The Date increment adds producer/assignment and call-site Date evidence, plus a direct-variable-only pin guard so a Date consumer does not pin integer offsets inside a compound expression.

Locals, parameters, block parameters and class members use lexical names. Global function names remain subject to the helper-name guard: BOTH ordinary FUNCTION header branches use check_global_ident. DO fname and PRIVATE/PUBLIC/MEMVAR controls are preserved from upstream. The final negative names_global.prg declares FUNCTION month, not CLASS month.

The captured Harbour contract probe calls month() and declares FUNCTION month(). Harbour reports E0008 (redefinition of predefined MONTH) and E0021 (the call supplies zero arguments, expected one). The evidence does not isolate an unused declaration. HBC's final named negative rejects the global declaration through check_global_ident. This does not add arbitrary builtin redefinition, class grammar, module STATIC or dynamic method names.

## Run and evidence

    python3 tests/names-date/check.py --compiler ./hbc --hbmk2 /external/hbmk2 --output /new/evidence

Add --wine /path/to/wine for PE execution and arrange the external oracle's MinGW toolchain (HB_CCPREFIX=x86_64-w64-mingw32-). The runner builds Harbour afresh from the same source and compares exit/stdout/stderr byte for byte. It records source and compiler hashes and raw streams. No CRLF or trailing-LF normalization is performed.

Final compiler SHA256: a08dc51ff9013ceb267c1357260645ff686865f27445633520c951d91c86dbc6. Gates on that compiler:
- 14 positive sources x Linux/PE-Wine = 28 fresh Harbour comparisons, exact.
- 5 named negatives x both targets = 10 correct rejections.
- FILE: 56/56 with fresh Harbour Linux/PE-Wine and internal/external engines.
- Classes Linux: 42/42 with fresh Harbour.
- PE object separators: 3/3 against captured fixtures.
- Compile-only PE CI: 1730 PASS, 21 recorded mismatches, 0 unexpected failures.

These are bounded gates. No native Windows executor or full root runtime battery was run here. Documentation-only follow-ups do not change this compiler hash. Do not substitute older candidate gate totals for these results.

## Date parameter pilot

CDow/DoW/DToS/Year/Month/Day/CMonth/DToC supply Date evidence for a direct parameter. Date()/SToD()/CToD(), a known Date-returning call or a local Date can supply assignment evidence. Call-site Date evidence propagates through identity/forwarding functions and methods; Date remains distinct from numeric I64. This increment does not change runtime calendar encoding.

Nine Date sources cover consumers including empty dates, assignment, local copies, forwarding, recursion, methods, a ValType guard, the forwarded CDow regression, and CToD/DToC together. Empty-date strings are bracketed to avoid a pre-existing Windows terminal difference on trailing blank-only output. Explicit Str widths avoid claiming a fix to numeric-width metadata. Current-date checks compare values inside the program rather than fixing a calendar date in the fixture.

This is monomorphic Date transport/inference, not arbitrary parameter retyping or flow-sensitive narrowing of NIL/numeric/logical/string variants. Omitted arguments, integer arguments, mixed Date/string calls and literal NIL passed to a Date parameter retain named rejections. date_nil_argument really passes NIL; date_nil_assignment is a different positive case and does not prove acceptance of NIL. Date by-reference and general Date arithmetic inference are not newly supported. Several original corpus functions still need predicates, variant narrowing, arithmetic or libraries. No claim that all nine original Date-related corpus routes now compile.

## Provenance

names_reported.prg and date_reported.prg are tiny reproducers forwarded by the owner in the supplied reported-three ZIP, not newly authored tests. Their source hashes are recorded in results.json. All other names-date sources are own synthetic probes. No Harbour implementation bodies are copied; Harbour remains an external oracle.
