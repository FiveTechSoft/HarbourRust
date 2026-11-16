# Names and Date parameter regression probes

Own probes; Harbour stays an external oracle. Run from a built checkout:

    python3 tests/names-date/check.py --compiler ./hbc --hbmk2 /external/hbmk2 --output /new/evidence --group names

Add `--wine /path/to/wine` for PE execution and arrange the external oracle's MinGW toolchain (`HB_CCPREFIX=x86_64-w64-mingw32-`). The runner builds Harbour afresh from the same source, checks exit/stdout/stderr byte for byte, and records hashes and raw streams. It never normalizes CRLF or updates golden bytes. All sources are own test code. No original corpus source is copied.

Names fix: local variables, parameters, block parameters and class members are lexical names, not global code-generator helper labels. `check_ident` checks length; only ordinary global function declarations keep the helper-name restriction. Methods already lower to class-qualified functions and local/parameter slots already use offsets. Builtin calls stay calls even when a variable or member uses the same text.

Fresh own probes at base 739655b4 plus names change: 4 sources x Linux/PE under Wine = 8 exact oracle comparisons. Tests cover month/str/Left/Right locals and parameters, array local aSize, method Str/Left/Right/Month/aSize, ordinary builtin calls alongside those names, block shadowing and FOR counters. More scalar arithmetic/builtin behavior remains the existing compiler's contract; explicit Str widths avoid claiming Harbour's separate numeric-width metadata is newly implemented.

Limits: global helper-name functions remain rejected. This does not add unsupported class grammar, global STATIC, arbitrary builtin redefinition, dynamic method names or year-zero handling. Wine is not native Windows verification.

## Date parameter pilot

Date-consuming builtins (CDow/DoW/DToS/Year/Month/Day/CMonth/DToC) now pin a directly used parameter Date instead of leaving an integer placeholder. Assignment of Date()/SToD()/CToD(), a known Date-returning call or a local Date also supplies evidence. Ordinary call-site Date evidence propagates through identity/forwarding functions and methods; Date remains distinct from numeric I64. No runtime implementation or date calendar encoding changed.

Seven own Date sources cover consumers including empty dates, Date() assignment, assignment through a local Date, forwarding/identity, recursion, methods and the ValType guard used by defaulting code. Positive source/target comparisons are raw-exact. Strings are bracketed in the empty-date probe to avoid claiming a fix to the pre-existing Windows terminal handling of trailing blank-only output; no stream normalization occurs. Current-date checks compare values inside the program rather than pinning a calendar date in the fixture.

Explicit limits: this is monomorphic Date transport/inference, not arbitrary Harbour parameter retyping or flow-sensitive narrowing of NIL/numeric/logical/string variants. Omitted Date arguments, a wrong integer and a mixed Date/string call retain named rejections (negative tests). Date by-reference and Date arithmetic-inference contexts are not newly supported. Some corpus functions still require dynamic type predicates, variant narrowing, arithmetic and library support. No year-zero change and no claim that all 9 Date-related corpus routes now compile. Linux-hosted Wine is not a native Windows executor.

Final combined-candidate gate: 13 positive sources x 2 targets = 26 raw-exact comparisons (including the two forwarded regressions with matching source hashes), plus 4 named negatives x 2 = 8 rejection checks. FILE 56/56 with fresh external Harbour Linux/PE-Wine, class gate 42/42 fresh Linux, Windows object separators 3/3 captured fixtures, compile-only PE manifest 1727 PASS / 21 recorded mismatches / 0 unexpected. These are bounded gates, not a claim that all original sources or all runtime paths pass.
