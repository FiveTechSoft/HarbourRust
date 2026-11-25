# Rebuilt two-argument binary At

Fresh own MIT reconstruction after environment loss,on4042fca0 BSubStr.
Not recovered161529d7/9ad1772b and no old PASS/raw evidence reused.
Ordinary Linux profile only,no threads/macros. Exactly two typed string
leaves:needle,haystack. Literal/variable only,no computed/effectful arguments,
Dyn cells,optional start/end bounds or non-Linux runtime expansion.
Returns1-based byte position of first exact match;0 for empty needle,
missing match or needle longer than haystack. NUL/UTF8 counted bytes.
Both inputs borrowed,no new allocation or ownership operation. Own simple
bounded byte comparison loop,not copied from Harbour implementation.

Gate47 freshly measured:4positive sources by5modes=20exact Harbour runs,
4strict zero final balances,16profile rejections,7named limits. Includes
all65536single-byte needle/haystack pairs,empty inputs,overlaps,near-end
match,UTF8/NUL,owned variable retention/repeats,user parameters. Modes
native,external-as,flat,noescape,noprune. Initial basic fixture mistakenly
passed Chr(0) directly and was correctly rejected by leaf restriction;
changed to a local variable. One failed Rust build had checker inserted at
the wrong helper location;fixed before any successful gate. Failed logs
retained,not counted as passes.

Fresh regression:12relevant prior suites PASS with current compiler hashes,
including rebuilt BSubStr. Rust106,LLVM21exact fresh,Linux manifest1181exact
stdout/stderr/rc. PE emission1916PASS/22known/0FAIL,no runtime claim.
622negative cases diagnostics/status identical vs newly built15607b62base
acrossLinux/Windows.1041original compile census identical,58admitted.
Not full replay of all prior suites:external Julio ASort corpus unavailable
until original reforward. No old regression PASS inherited.No original
closure or speed claim.RC/objects,numeric-array division parked.

CompilerSHA256c287fe722804acd9c09d0fc69c0326e0279fa16e01834172bd2745a2f910a0ab.
Oracle git694428e1c12f726675b19324d62167fa77d68185 built fresh;
hbmk2SHA2562fb1503a38760b9e94617fd6243ec0a8f65c6a84e079fed0efc47d66633c40ae.
Rust1.100.0. Compared published-base compilerSHA256
2391469410837657235c212d09f270438553e15030ddfc4ba304a9aef581ac68.
Exact input/hash,argv/cwd,separate build/run rc/stdout/stderr retained.
Julio Ponce MIT specifications credited,no supplied implementation or
cambio.diff used.No push/publication/workflows/rebase.Package no generated
binaries/objects/disposable assembly.Requires new C2 review.

python tests/byte-at/check.py --compiler target/release/hbc --hbmk2 /path/hbmk2 --spec-root /path/harbour --output /new/path
