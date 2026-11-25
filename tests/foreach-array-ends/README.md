# Fresh rebuilt scalar-array enumeration endpoints

Own MIT postreset implementation on4574c171,reconstructed from supported
semantics and fresh Harbour oracle. Not recovered09676860,no prior PASS
reused. __enumIsFirst/__enumIsLast admit active readonly Dyn iterators of
already-supported scalar arrays,ordinaryLinux only. Hash behavior retained;
enumKey stays hash-only. No objects,string iteration,borrowed nested-array
values,setters,byref,DESCEND,multi-enum,macro/block/shared-profile expansion.
No new allocation or ownership operation. Lexical emission stack records
index and either fixed stack-array count or dynamic saved-length slot.

Gate86=8ownpositive sources by5modes40exact Harbour runs,8strict-zero final
balances,32profile rejections,6named limits. Empty/single/multi,static integer
array,string/logical elements,owned Array()temporaries,repetition,LOOP/EXIT/
earlyRETURN,Boolvariables,nested names same/distinct,array-array/hash-array/
array-hash with outer getter restoration. Two formerly rejected hash-gate
sources moved intact to positives:hashgate44now,not historical46. Key/string/
args/capture/outside/hash-mutation limits remain.Capture/string reject at
existing guards,not new protection.

Fresh regression15relevant prior suites with currentSHA PASS,Rust106,
LLVM21fresh exact,Linux1181exact stdout/stderr/rc,PE emission1916PASS/
22known/0FAIL,no runtime claim. Negative622diagnostics/status identical vs
fresh published-base15607b62 acrossLinux/Windows;census1041identical58admitted.
No full replay:external Julio ASort original corpus missing pending reforward.
No original closure/speed claim.RC/objects,numeric-array division parked.
Compiler af5fc2625c482be634f681869328c57ba32c0e803397caf32cd1c2e68f3b2bcd.
Oracle git694428e1c12f726675b19324d62167fa77d68185,hbmk2SHA256
2fb1503a38760b9e94617fd6243ec0a8f65c6a84e079fed0efc47d66633c40ae.
Exact inputs/hash,argv/cwd,build/run streams/status included.Julio Ponce MIT
specifications credited,no supplied implementation/cambio.diff copied.
No push/publication/workflows/rebase.No generated binaries/objects/assembly
in compact package.Requires new C2.

python tests/foreach-array-ends/check.py --compiler target/release/hbc --hbmk2 /path/hbmk2 --spec-root /path/harbour --output /new/path

Conditional review follow-up:two mandatory limits AAdd/ASize on the borrowed
array with __enumIsLast inside FOR EACH require rc1,no executable and the
existing diagnostic containing 'the loop borrows it'. Dedicated fresh
negative evidence uses a separate direct-release build of exact source
edab2a3395aff5639456f5fed2a92d6991642902,not the working string-enum compiler.
No implementation change in this follow-up.

String-enum follow-up moves limit-string intact to its positive basic.
The array gate after both conditional-review mutator additions and that
move is87checks;prior86count refers to original edab2a33.
