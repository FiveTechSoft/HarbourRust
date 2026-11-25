# hb_FNameExtSetDef Linux string leaves

Own MIT on a930e867. Julio Ponce MIT examples remain independent specifications,no supplied implementation/cambio.diff copied. Fresh Harbour oracle;source tree lacks git metadata,source commit unverified,hbmk2 hash included.

Exactly two typed-string leaves,literal/variable,ordinary native Linux x86-64 without threads/macros. Reuses own extension helper with default-only flag:if a last-dot extension exists after first basename byte,preserve the measured263-byte/NUL path prefix,instead of replacing/appending. A trailing dot counts as extension;initial dot alone does not. Output still capped262bytes,including preserved-extension case. Otherwise same measured dot insertion/NUL behavior as ExtSet. Slash Linux,backslash ordinary byte. Independent owned result,inputs borrowed/retained,including same variable twice. No computed/call/index/assignment arguments,no evaluation-effect or filesystem/RC/object claim.

Gate36:3 own intact sources in5 modes=15exact Harbour,3strict-zero balances,12profile rejections,6limits. Empty,existing/missing/trailing extension,dotfiles,multiple dots,directories,backslash,NUL both inputs,path255..270,extension270,same-variable aliases,inferred string parameters/return. Existing ExtSet gate36 rerun on modified shared helper.

Regression130prior native suites PASS reconciled by name,127result files with compiler SHA checked where present. Rust106,LLVM21fresh exact,Linux1177stdout/golden,PE emission-only1912PASS/22known/0FAIL,negative622same18,census58/1041unchanged. No original closure/speed claim,paired benchmark not rerun. RC/objects and numeric-array division parked. No push/publication/workflows/rebase.

python tests/fname-ext-set-def/check.py --compiler target/release/hbc --hbmk2 /path/hbmk2 --spec-root /path/harbour --output /new/path
