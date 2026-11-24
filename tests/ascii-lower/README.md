# hb_ASCIILower Linux

Own MIT on a814468a. Julio Ponce's MIT programs are independent specifications,no implementation/cambio.diff copied. Fresh Harbour oracle;extracted source tree lacks git metadata,source commit unverified,hbmk2 hash included.

One typed string expression,ordinary native Linux x86-64 without threads/macros. Independent owned byte copy,changes only ASCII A..Z to a..z. NUL and bytes128..255 unchanged;not locale/codepage-aware Lower or Unicode casefold. Reuses own ASCIIUpper helper pattern,not upstream implementation. Borrowed variables retained,temporary string arguments freed. No RC/object/numeric-array policy change. No Dyn/coercion/extra args.

Gate25:2 own intact sources in5 modes=10exact Harbour,2strict-zero balances,8profile rejections,5limits. All256bytes,UTF-8 byte payload,NUL followed by ASCII,empty,punctuation,length4097,owned Upper/concat,reused variable,function parameter/return,ASCIIUpper composition. No non-Linux runtime claim.

Regression127prior native suites PASS reconciled by name,124result files compiler SHA checked where present. Rust106,LLVM21fresh exact,Linux1177stdout/golden,PE emission-only1912PASS/22known/0FAIL,negative622same18,census58/1041unchanged. No original closure or speed claim,paired benchmark not rerun. RC/objects and numeric-array division parked. No push/publication/workflows/rebase.

python tests/ascii-lower/check.py --compiler target/release/hbc --hbmk2 /path/hbmk2 --spec-root /path/harbour --output /new/path
