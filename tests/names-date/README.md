# Names and Date parameter regression probes

Own probes; Harbour stays an external oracle. Run from a built checkout:

    python3 tests/names-date/check.py --compiler ./hbc --hbmk2 /external/hbmk2 --output /new/evidence --group names

Add `--wine /path/to/wine` for PE execution and arrange the external oracle's MinGW toolchain (`HB_CCPREFIX=x86_64-w64-mingw32-`). The runner builds Harbour afresh from the same source, checks exit/stdout/stderr byte for byte, and records hashes and raw streams. It never normalizes CRLF or updates golden bytes. All sources are own test code. No original corpus source is copied.

Names fix: local variables, parameters, block parameters and class members are lexical names, not global code-generator helper labels. `check_ident` checks length; only ordinary global function declarations keep the helper-name restriction. Methods already lower to class-qualified functions and local/parameter slots already use offsets. Builtin calls stay calls even when a variable or member uses the same text.

Fresh own probes at base 739655b4 plus names change: 4 sources x Linux/PE under Wine = 8 exact oracle comparisons. Tests cover month/str/Left/Right locals and parameters, array local aSize, method Str/Left/Right/Month/aSize, ordinary builtin calls alongside those names, block shadowing and FOR counters. More scalar arithmetic/builtin behavior remains the existing compiler's contract; explicit Str widths avoid claiming Harbour's separate numeric-width metadata is newly implemented.

Limits: global helper-name functions remain rejected. This does not add unsupported class grammar, global STATIC, arbitrary builtin redefinition, dynamic method names or year-zero handling. Wine is not native Windows verification.
