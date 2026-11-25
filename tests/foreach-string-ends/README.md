# Fresh corrected byte-string enumeration observations

Own MIT rebuilt implementation after environment loss,on984e8fc3.
Not recovered16bf7616/9d9a94bb/4cd822a2,no old PASS or evidence reused.
__enumIndex/__enumIsFirst/__enumIsLast observe readonly typed-string
iterators in existing observation-only FOR EACH,ordinaryLinux only.
Existing index/length slots,no new allocation or ownership operation.
Harbour semantics measured as bytes:UTF8multibyte sequences occupy multiple
iterations,NUL is ordinary byte.No Unicode-character interpretation.

Receiver proof present from start:filter requires current iterator name or
lexically active outer iterator;getter spelling alone never grants pure
observation. General checker also proves readonly Dyn/Str/arity.Parameter
string inference uses the same receiver proof. Builtin whitelist uses
is_builtin,which respects user-function names. No enumKey,setters,storage,
assignment,user calls,loops inside string-loop bodies,mutation,macro/block/
shared-profile or non-Linux expansion.

Gate95fresh:8ownpositive sources by5modes=40exact Harbour runs,8strict final
zero balances,32profile rejections,15named limits. Empty/singleton/all256bytes/
UTF8/NUL,repetition,LOOP/EXIT/bareRETURN,comparison,outer array/hash inner
string same-name restoration,distinct-name outer getter observations,and
parameter-string observer. Modes native,external-as,flat,noescape,noprune.
Old array limit-string moved intact to positive basic;array gate87now
(original86 plus2mutator limits minus1moved string limit),not silently lost.

Three direct user-object getter methods with visible MUST-NOT-RUN reject
by observation guard. Three outer arrays of user-class objects with the
same methods reject earlier by existing array-element restriction;this is
rejection evidence,not successful object-array iteration.User Len homonym
rejects earlier as reserved code-generator name,not a new purity check.
Other limits cover args/storage/key/mutation/nested/stringnoniterator/after/
key-shadow. Each asserts diagnostic,rc1,no executable.

Fresh regression16relevant prior suites with SHAcurrentPASS,Rust106,
LLVM21fresh exact,Linux1181exact stdout/stderr/rc,PE emission1916PASS/
22known/0FAIL(no runtime claim). Negative622diagnostics/status identical to
fresh published15607b62base acrossLinux/Windows;census1041identical58admitted.
Not full suite replay:external Julio ASort corpus missing until reforward.
No original closure/speed claim.RC/objects,numeric-array division parked.
Compiler aa8cb65c93c5ca8999274fb28dd25e85dff8fcee6aedad394f09751dc52d6986.
Oracle git694428e1c12f726675b19324d62167fa77d68185,hbmk2SHA256
2fb1503a38760b9e94617fd6243ec0a8f65c6a84e079fed0efc47d66633c40ae.
Raw fresh inputs/hash,commands/cwd,build/run status/streams included.Julio
Ponce MIT specifications credited,no supplied implementation/cambio.diff
copied.No push/publication/workflows/rebase.No generated binaries/objects/
disposable assembly in package.Requires fresh C2.

python tests/foreach-string-ends/check.py --compiler target/release/hbc --hbmk2 /path/hbmk2 --spec-root /path/harbour --output /new/path
