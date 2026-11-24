# hb_DirSepToOS Linux

Own MIT increment on20f03b03. Julio Ponce's MIT examples remain independent specifications, no supplied implementation or cambio.diff copied. Fresh Harbour oracle; extracted tree has no git metadata, source commit not verified, hbmk2 hash included.

One typed string expression,ordinary native Linux x86-64 without threads/macros. Copies counted bytes into independent owned result and changes each backslash byte to slash. Does not collapse separators,normalize Unicode,query filesystem or apply path-length caps. Embedded NUL is retained and subsequent bytes still converted,measured with Harbour. Variables are borrowed and retained; temporary string arguments freed after copying. No RC/object policy change. Extra arguments are deliberately rejected even though the measured Harbour ignores them;not full API compatibility.

Gate25:2 own intact sources in5 modes=10exact fresh Harbour,2strict-zero balances,8profile rejections,5limits. Empty,slash,one/two backslashes,mixed slash/backslash,drive-like,NUL,300-byte prefix,UTF-8 bytes,owned Lower/concatenation,reused variable,function parameter/return,DirSepAdd composition. No Dyn/coercion. No non-Linux runtime claim.

Regression125prior native suites reconciled by name,122result files with compiler SHA checked where present. Includes strengthened fname-parts45 and fname-nameext45. Rust106,LLVM21fresh exact,Linux1177stdout/golden,PE emission-only1912PASS/22known/0FAIL,negative622same18,census58/1041unchanged. No original closure or speed claim;paired benchmark not rerun. RC/objects and numeric-array division parked. No push/publication/workflows/rebase.

python tests/dir-sep-to-os/check.py --compiler target/release/hbc --hbmk2 /path/hbmk2 --spec-root /path/harbour --output /new/path
