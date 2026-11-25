# Two-leaf binary reverse search

Own MIT hb_BRAt(needle, haystack), Linux ordinary profile only, no threads
or macros. Exactly two typed string literal/variable leaves. Optional
bounds, computed/effectful arguments, Dyn strings and other target profiles
remain rejected. Returns last exact byte match, 1-based, or 0 for missing
match, empty needle, or needle longer than haystack. UTF8 and NUL are bytes.
Both inputs borrowed. No allocation, ownership expansion or reference-count
change. Simple bounded reverse byte comparison, original implementation.
Julio Ponce MIT programs credited as specifications only. No implementation
or cambio.diff copied. No original-program closure or speed claim here.

Fresh oracle git694428e1c12f726675b19324d62167fa77d68185,
hbmk2 SHA2562fb1503a38760b9e94617fd6243ec0a8f65c6a84e079fed0efc47d66633c40ae.
Gate67:6sources x5modes=30exact stdout/stderr/status runs,6strict final zero
balances,24profile rejections,7named unsupported-form rejections. Includes
65536single-byte pairs,19856variable length/start/count slices searched in
34haystacks, empty inputs, NUL/UTF8, overlaps, end matches, owned variable
retention, typed function parameters, and BAt/BRAt coexistence. Modes native,
external-as,flat,noescape,noprune. Current compiler SHA256
2aa6dc15b271804a260d7a060c89bb089f36b5386e05e8879412d81a4b6e45f0.

Fresh current-compiler regression:16prior suites with SHA check, string enum
116, mandatory intact-original wrapper190exact/balance passes+2known debts
(inhprob/classch DELTA2, not zero/lifetime passes), Rust106, LLVM21exact
(native/traced/untraced with LLVM15). Linux manifest1181exact stdout/stderr/
status. Negative622unchanged against fresh published15607b62 on Linux and
Windows, original compile census1041unchanged,58admitted. PE1916PASS/22known/0FAIL,
emission only, never execution. Not full historical replay: external Julio
ASort original corpus remains absent after reset; original reforward needed.
No inherited old PASS. Numeric-array division and RC/object lifetime parked.

New commit above6032a99a, no push/publication/workflows/rebase. Package carries
bundle/patch/manifest, exact copied inputs/hashes, command/cwd, separate
build/run rc/stdout/stderr. Disposable binaries/objects/assembly excluded;
src/brat_linux.s is hand-authored production source, not disposable output.

python tests/byte-rat/check.py --compiler target/release/hbc --hbmk2 /path/hbmk2 --spec-root /path/harbour --output /new/path
