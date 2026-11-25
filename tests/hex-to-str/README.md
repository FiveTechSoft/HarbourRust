# hb_HexToStr Linux

Own MIT on c7bed8a3. Julio Ponce's MIT programs remain independent specifications only,no supplied implementation/cambio.diff copied. Harbour fresh oracle,extracted source tree lacks git metadata,source commit unverified,hbmk2 hash included.

One typed string expression,ordinary native Linux x86-64 without threads/macros. Two-pass byte decoder:count ASCII hex digits,allocate floor(count/2),then pair high/low nibbles. Upper/lowercase accepted,all nonhex bytes ignored,unpaired final nibble discarded. Thus 0x41 produces byte04,not41. NUL and nonASCII bytes are ignored as nonhex and do not terminate input. All measured with fresh Harbour. Result independently owned;variables borrowed/retained,temporary string arguments freed. No RC/object/numeric-array policy change. No Dyn/coercion or extra arguments.

Gate35:3 own intact sources in5 modes=15exact Harbour,3strict-zero balances,12profile rejections,5limits. Empty,case,binary00/FF,odd nibble,invalid chars,spaces,prefix-looking input,NUL,UTF-8 noise;all256bytes and full binary roundtrip through StrToHex,1025repeated noisy groups,owned Lower/concatenation,reused variable,function parameter/return. No non-Linux runtime claim.

Regression126prior native suites PASS reconciled by name,123result files compiler SHA verified where present. Rust106,LLVM21fresh exact,Linux1177stdout/golden,PE emission-only1912PASS/22known/0FAIL,negative622same18,census58/1041unchanged. No original closure/speed claim,paired benchmark not rerun. Numeric-array division and RC/objects parked. No push/publication/workflows/rebase.

python tests/hex-to-str/check.py --compiler target/release/hbc --hbmk2 /path/hbmk2 --spec-root /path/harbour --output /new/path
