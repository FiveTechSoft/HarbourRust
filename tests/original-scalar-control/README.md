# Mandatory intact upstream scalar and syntax controls

Own MIT test-only increment on9e422bd1. Upstream originals are read from --spec-root, copied only into evidence with their hashes. They remain external specifications. Julio Ponce's MIT programs remain independent specifications; no implementation or cambio.diff copied.

Nine mandatory intact originals:comments,define,docase,exit,ifelse,parexpr,while,vec1,lnlenli2. No edited source or replacement Main. Missing source is failure.45 exact fresh Harbour executions in five native Linux modes (native,external-as,flat,noescape,noprune),rc0 and stderr empty;9 strict-zero final heap probes. Timeout fails. Inputs,hash,argv/cwd,separate build/run rc/stdout/stderr and hbmk2 hash retained. define intentionally compiles without TEST define on both compilers; build warning is recorded, not ignored runtime output.

This makes existing behavior mandatory evidence; it is not nine new implementation closures. No compiler change, no speed or new target claim. Compiler SHA256263cd7a814ae7027d9a12f90b55b06c68a332b7eacfee31a79bbe35a372828a1 unchanged. Full global regression not repeated for tests-only commit. Last compiler9e422bd1 had122 prior native suites,Rust106,LLVM21 fresh exact,Linux1177,PE emission1912PASS/22known/0FAIL,negatives622 same18,census58/1041 unchanged. Object lifetime debt and numeric-array division remain parked.

Harbour tree has no git metadata; source commit not verified. No push/publication/workflows/rebase. Package excludes generated binaries/objects/disposable assembly.

python tests/original-scalar-control/check.py --compiler target/release/hbc --hbmk2 /path/hbmk2 --spec-root /path/harbour --output /new/path
