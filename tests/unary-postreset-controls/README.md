# Fresh current-compiler unary controls

Own MIT tests-only on6d83ee98 after environment loss. New runner and fresh
execution,not recovered0bfd8eb1 or old PASS. Reuses existing fixture sets:
ASCIIUpper17,DirSepAdd16,HexToNum40,base64Encode39,StrToHex17,OSDrive8.
137sources,274exact Linux executions(internal/external assembler),137strict
final zero balances,total411PASS. No obsolete rejecting compiler required.
Current compilerSHA256
c287fe722804acd9c09d0fc69c0326e0279fa16e01834172bd2745a2f910a0ab unchanged.

Includes NUL/all256bytes/UTF8/70KiB,boundary lengths,retained values,cache
reuse,parameters,effects/throws as present in prior source sets. Five throw
fixtures (ASCIIUpper,base64Encode,DirSepAdd,HexToNum,StrToHex) adapt TRY/CATCH to Harbour SEQUENCE/RECOVER;both inputs retained.
No default-handler equivalence claimed. Strict guard checks rc/stdout/stderr,
not absentDELTA alone. All source/fixture/runner/guard hashes,commands/cwd,
separate build/run status/streams and oracle commit/hash retained.
Oracle fresh git694428e1c12f726675b19324d62167fa77d68185,hbmk2SHA256
2fb1503a38760b9e94617fd6243ec0a8f65c6a84e079fed0efc47d66633c40ae.

No global repeat tests-only.No implementation/original closure/speed claim.
External Julio ASort corpus unavailable pending reforward,not skipped green.
RC/objects,numeric-array division parked.Julio Ponce MIT specifications
credited,no implementation/cambio.diff copied.No push/publication/workflows/
rebase.Package excludes generated binaries,objects,disposable assembly.

python tests/unary-postreset-controls/check.py --compiler target/release/hbc --hbmk2 /path/hbmk2 --spec-root /path/harbour --output /new/path
