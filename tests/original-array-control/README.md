# Mandatory intact upstream array controls

Own MIT test-only increment on769e7343. External Harbour originals remain specifications,not copied into this MIT directory. Evidence copies exact inputs with hash. Julio Ponce's MIT examples remain independent specifications;no implementation/cambio.diff used.

Six mandatory intact originals:ains,array,array16,arrays,arreval,arrindex.
30exact fresh Harbour runs in five Linux modes(native,external-as,flat,
noescape,noprune),rc0 and empty stderr;6strict-zero final heap probes.
No source edits,replacement Main or optional skip. Includes existing
array cycle creation/breaking,nested mixed indexes,large arrays,shifts,
resize/fill/clone and AEval behavior of those actual originals. Missing
input or timeout fails. Input/hash,argv/cwd,build/run rc/stdout/stderr
and hbmk2 hash retained. Tree lacks git metadata,source commit unverified.

Mandatory repeatable evidence,not six new implementation closures or a
new sharing/RC grant. Compiler unchanged SHA256
 a057f720f4f3ce31fcf914834d82dce60ecdd3d153f5e6b6590edfde67fe4d04.
Full global not repeated for tests-only commit;latest compiler769e7343
had127prior native suites,Rust106,LLVM21fresh,Linux1177stdout/golden,
PE emission-only1912PASS/22known/0FAIL,negative622same18,census58/1041.
Numeric-array division and RC/objects remain parked. No speed claim.
No push/publication/workflows/rebase. Package excludes generated binaries,
objects and disposable assembly.

python tests/original-array-control/check.py --compiler target/release/hbc --hbmk2 /path/hbmk2 --spec-root /path/harbour --output /new/path
