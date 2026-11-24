# hb_BLeft / hb_BRight Linux byte slices

Own MIT on6da4a6df. Julio Ponce MIT examples remain independent specifications,no supplied implementation/cambio.diff copied. Fresh Harbour oracle;source tree lacks git metadata,source commit unverified,hbmk2 hash included.

Exactly two leaves:typed string literal/variable and integer literal/variable,ordinary native Linux x86-64 without threads/macros. Own byte-slice helper clips count to0..byte-length and returns independent owned copy of prefix/suffix. Negative count returns empty;oversize count returns all bytes. Can split multibyte encoding;NUL retained. Not aliased to codepage-aware Left/Right. Inputs borrowed and retained. Computed/call/index/assignment/float/Dyn/extra args rejected;no effectful multiargument evaluation or coercion claim. No RC/object policy change.

Gate27:2own intact sources in5 modes=10exact fresh Harbour,2strict-zero balances,8profile rejections,7limits. Negative/zero/one/interior/oversize/extreme signed counts,empty,UTF-8 split,NUL,owned variable reused in101loops,variable count,inferred string/integer parameters and return. Final checker asserts named diagnostic;initial helper text replacement had a truthy bytes condition which was corrected and entire gate rerun as gate2. Only gate2 counts.

Regression133prior native suites PASS reconciled by name,130result files compiler SHA verified where present. Rust106,LLVM21fresh exact,Linux1177stdout/golden,PE emission-only1912PASS/22known/0FAIL,negative622same18,census58/1041unchanged. No original closure/speed claim,paired benchmark not rerun. RC/objects and numeric-array division parked. No push/publication/workflows/rebase.

python tests/byte-left-right/check.py --compiler target/release/hbc --hbmk2 /path/hbmk2 --spec-root /path/harbour --output /new/path
