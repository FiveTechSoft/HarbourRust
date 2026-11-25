# hb_BLen typed strings Linux

Own MIT on e3164dd0. Julio Ponce MIT programs remain independent specifications,no implementation/cambio.diff copied. Fresh Harbour oracle;source tree lacks git metadata,source commit unverified,hbmk2 hash included.

Exactly one typed string expression,ordinary native Linux x86-64 without threads/macros. Integer result is counted byte length,not characters or graphemes. NUL and high bytes counted. No new helper/scan/allocation for the result. Variables borrowed/retained,computed owned strings freed after saving length. Extra args rejected even though measured Harbour ignores them. No Dyn/coercion,array overload or codepage behavior claim. No RC/object policy change.

Gate25:2own intact sources in5 modes=10exact Harbour,2strict-zero balances,8profile rejections,5limits. Empty,ASCII,UTF-8,NUL,all256bytes with cumulative length,4097multibyte repetitions,HexToStr-produced binary,owned/reused variable,computed calls/concat,inferred string parameter/return. No non-Linux runtime claim.

Regression132prior native suites PASS reconciled by name,129result files compiler SHA verified where present;includes UTF8heuristic45. Rust106,LLVM21fresh exact,Linux1177stdout/golden,PE emission-only1912PASS/22known/0FAIL,negative622same18,census58/1041unchanged. No original closure/speed claim,paired benchmark not rerun. RC/objects and numeric-array division parked. No push/publication/workflows/rebase.

python tests/byte-len/check.py --compiler target/release/hbc --hbmk2 /path/hbmk2 --spec-root /path/harbour --output /new/path
