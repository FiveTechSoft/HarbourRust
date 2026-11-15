# MEMVAR bridge preparation

This unit does not wire hrmacro, compiler, blobs, error routing or the runtime registry. Its C harness uses the published storage source plus a deliberately fake compiler allocator. It is a design prototype, not an implementation of the production bridge.

## Gates observed

Official Harbour core 694428e1c12f726675b19324d62167fa77d68185, default hbmk2 -gtstd, ELF and PE/Wine:

- missing + returns syntax 1449 before attempting lookup.
- .F. .AND. missing and missing .AND. .F. both return .F.
- With PRIVATE v:=.F., v .AND. missing returns .F.; v .AND. 123 also returns .F. But 123 .AND. v raises BASE/1066, operation conditional. Runtime short circuit and operand order matter even when the right operand happens to equal a literal constant.
- .T. .OR. missing and PRIVATE v:=.T.; v .OR. missing return .T.
- 10/2 prints an integer when literal-only, v/2 prints two decimals with v:=10.
- Under the captured ErrorBlock/RECOVER, 10/0 and v/0 raise BASE/1340, operation /. A second PRG verifies both direct constant macro text and a LOCAL text variable also raise 1340. This contradicts the zero-return rule present in hrmacro.c at observed HEAD 631e29086a19119c31671938e8a4fbb1eade1f57. No product behavior was changed. The owner should reconcile its earlier oracle/configuration before selecting the fix; this unit does not silently replace that contract.

All four official runs naturally exit 0 with empty stderr because the PRGs deliberately catch and print errors. Their rc0 is not evidence that these expressions succeed. See stdout for the errors. These are official-oracle results, not HarbourRust parity.

## Isolated ownership prototype

bridge-client.c implements a local bridge_get prototype that copies storage-owned strings into a fake compiler allocator, then releases the storage copy through hrmv_value_free. Two independent exact-pointer/exact-size allocation lists reject wrong-pool frees. The fake compiler layout has capacity at -16 and length at -8, but uses malloc and no real compiler cache or registry. It reserves an extra NUL byte; this fake allocation size is not a claim about the production allocation formula.

Tested empty, 7-byte binary (including NUL), 4096-byte and 65537-byte strings. Checks include distinct pointers, caller input survival, copied value survival after releasing input, store-copy and compiler-copy allocation failures with output unchanged, transactional put failure, nested shadow/restore, truncated 63-byte name collisions, unsupported tags, zero raw/fake-compiler live bytes and balanced frees. ELF and PE/Wine raw output match. ASAN/UBSAN/leak detection is clean for ELF.

This does not prove real hbc registry transitions, hb_memcheck, emitted SysV or native Win64 wrappers, error cleanup through the production handler, fields, M-> parser support or frontend lifecycle. Those remain blocked on the error-contract prerequisite and the appropriate owner's wiring. hrmv frames are explicitly entered/left by the harness, not generated code.

## Reproduce

Run python3 reproduce.py from this evidence package. Override HB_CORE, HB_WINE, HB_CC and PROBE_OUT when installed at different paths. The script compiles one official binary at a time, captures raw streams and exit, compares with archived expected bytes, hashes each executable and removes it to avoid disk pressure. It builds and runs the prototype on ELF and PE and runs Linux sanitizers. No product files are edited.

For the proposed repository-only harness patch:

    gcc -std=c11 -Wall -Wextra -Werror -O2 tests/memvar/bridge-prototype.c runtime/hrmemvar.c -o /tmp/bridge-prototype
    /tmp/bridge-prototype

The patch adds tests/memvar/bridge-prototype.c and two standalone oracle PRGs plus this document. runtime/ snapshots in the evidence package are byte-identical supporting sources from the current commit, not patch changes.

## Limits

Preparation only. No production bridge, macro semantic fix or recoverable error-boundary implementation. No new storage types or release-mask/private-base support. The fake compiler allocator cannot establish production registry correctness or performance. Full macro parity remains the objective beyond this isolated stage.
