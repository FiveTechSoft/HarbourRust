# hb_StrIsUTF8 measured Linux byte-structure predicate

Own MIT on e6791ac3. Julio Ponce MIT examples remain independent specifications,no supplied implementation/cambio.diff copied. Fresh Harbour oracle;source tree lacks git metadata,source commit unverified,hbmk2 hash included.

One typed string expression,ordinary native Linux x86-64 without threads/macros. Bool true only if input contains at least one multibyte group and every high-bit sequence has the measured leading-one count followed by continuation bytes10xxxxxx. ASCII-only and empty return false. Accepts overlong forms,surrogates,values above Unicode range and legacy5..8-byte groups,including FE+6continuations and FF+7continuations. This deliberately matches Harbour's observed heuristic,NOT modern UTF-8/RFC3629 validation and must not be used as a security/Unicode-validity check. NUL treated as ASCII byte,does not terminate scan. No decoding/codepage conversion. Inputs borrowed,computed temporary strings freed;Bool creates no new owned value. Extra args/Dyn/coercion rejected. No RC/object policy change.

Gate35:3 own intact sources in5 modes=15exact fresh Harbour,3strict-zero balances,12profile rejections,5limits. Exhaustive lead0..255 with0..8continuations,and every byte0..255 in every continuation position of every lead192..255. ASCII/empty,UTF-8 payload,NUL plus invalid tail,overlong/surrogate/out-of-range,owned/repeated variables,function parameter/return. First two development gates exposed FE then FF legacy groups;corrected and final expanded gate4 alone counts. Raw failed attempts remain separate,not passes.

Regression131prior native suites PASS reconciled by name,128result files compiler SHA checked where present. Rust106,LLVM21fresh exact,Linux1177stdout/golden,PE emission-only1912PASS/22known/0FAIL,negative622same18,census58/1041unchanged. No original closure/speed claim,paired benchmark not rerun. RC/objects and numeric-array division parked. No push/publication/workflows/rebase.

python tests/str-is-utf8/check.py --compiler target/release/hbc --hbmk2 /path/hbmk2 --spec-root /path/harbour --output /new/path

Mixed-sequence follow-up,tests-only on e24df0a3:512deterministic byte
strings(length0..24,seed240112026) and256compositions around all64high
leads:ASCII prefix/suffix,NUL between groups,stray continuation and
truncated tail. Fixed bytes embedded as hex,not runtime randomness.
Gate expands35to45:20exact,4zero,16profile,5limits. This is further
heuristic compatibility evidence,NOT proof of valid Unicode or safe
security filtering. Compiler unchanged3518b33d1b5c487e4a9c9f33de5217b426e15f9a776ca3e6fd595e35beac1216.
No global repeat for tests-only commit.
