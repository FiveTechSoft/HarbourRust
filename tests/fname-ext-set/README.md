# hb_FNameExtSet Linux string leaves

Own MIT on cd8ecabb. Julio Ponce MIT examples are independent specifications only,no supplied implementation/cambio.diff used. Fresh Harbour oracle;extracted source tree lacks git metadata,source commit unverified,hbmk2 hash included.

Exactly two typed string leaves,literals or variables,ordinary native Linux x86-64 without threads/macros. Path scan stops at first NUL or263bytes. Last dot after first basename byte removes extension,slash resets basename. New extension stops at first NUL;prepend dot unless empty/already starts dot. Output capped262bytes,measured for this oracle/platform. Directories retained;backslash ordinary Linux byte. Independent owned result,inputs borrowed and retained,including same variable twice. No filesystem/RC/object policy change. Computed/call/assignment/index arguments rejected:effectful two-argument evaluation/cleanup not claimed. Generic user-function calls still obey existing move rules.

Gate36:3own intact sources in5 modes=15exact Harbour,3strict-zero balances,12profile rejections,6limits. Empty,dotfiles,multiple dots,directories,backslash,NUL in either input,extension with/without dot,slash in extension,path255..270 and extension270,caps after combined path/ext;owned variables repeated/same variable twice and inferred string parameters/return. Initial gate failed because fixture read s/e after passing them to an ordinary user function;fixture now prints before that move. No production widening for that failure;only final gate counts.

Regression129prior native suites PASS reconciled by name,126result files with compiler SHA checked where present. Rust106,LLVM21fresh exact,Linux1177stdout/golden,PE emission-only1912PASS/22known/0FAIL,negative622same18,census58/1041unchanged. No original closure/speed claim,paired benchmark not rerun. RC/objects and numeric-array division parked. No push/publication/workflows/rebase.

python tests/fname-ext-set/check.py --compiler target/release/hbc --hbmk2 /path/hbmk2 --spec-root /path/harbour --output /new/path
