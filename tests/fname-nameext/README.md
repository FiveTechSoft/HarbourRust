# hb_FNameNameExt Linux

Own MIT increment on d21db7f2. Julio Ponce's MIT programs remain independent specifications only; no supplied implementation or cambio.diff used. Harbour upstream is the fresh differential oracle; extracted source tree has no git metadata, source commit unverified, hbmk2 hash included.

One typed string expression, ordinary native Linux x86-64 without threads/macros. Reuses the measured path scan from hb_FNameExt/Name/Dir, preserves name plus extension after last slash, and returns an independent owned string. Backslash and colon remain ordinary Linux bytes. First NUL terminates input. The oracle scans at most263 input bytes, then returns at most262 basename bytes for this getter. This second cap differs from hb_FNameName; both caps and their order are explicitly measured, not asserted for all Harbour builds/platforms. Variables are borrowed and retained; temporary string arguments freed after copying. No filesystem/RC/object change.

Gate35:3 own intact sources in5 modes=15 exact fresh Harbour runs;3 strict-zero balances;12 profile rejections;5 named limits. Empty,name/extensions,dotfiles,dots,slash,backslash,colon,space,NUL;255/259/260/261/262/263/264/511/4096-byte prefixes both with slash and with extension;owned Lower/concatenation,repeated variable,function parameter/return,DirSepAdd composition. Typed string only, no Dyn/coercion.

Final compiler regression:124 prior native suites reconciled by name,121 result files with compiler SHA checked where present. Rust106,LLVM21 fresh exact,Linux1177 stdout/golden,PE emission-only1912PASS/22known/0FAIL,negative622 same18 mismatches,census58/1041 unchanged. The paired-speed runner is separate and was not rerun for this compiler; prior timings do not become timings for this increment. No original closure or new speed claim. Numeric-array division and RC/objects remain parked. No push/publication/workflows/rebase.

python tests/fname-nameext/check.py --compiler target/release/hbc --hbmk2 /path/hbmk2 --spec-root /path/harbour --output /new/path

Boundary follow-up on aaba4f6f,tests only: boundary-paths.prg adds slash
positions259..264,extension positions and directory prefixes near the cap,
NUL before/after cap,UTF-8 byte paths,all-slash oversized paths. Byte
behavior only,no Unicode normalization or character-counting claim.
Gate expands35 to45:20exact,4strict-zero,16profile rejects,5limits.
Compiler unchanged13f71f9fabf999778014a6b829efab171c2e4d55eb1201d0b9d314d3c6830e6b.
