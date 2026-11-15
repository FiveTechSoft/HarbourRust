# B1: isolated MEMVAR storage and ownership bridge

BASE: ef7ef7889f0939abd0dc9de4b9c117d1a58aa091

This is an internal C unit. It does not enable the frontend or evaluator and does not establish M0 conformance. QOut remains frozen behind B2. No compiler source, generated production blob, assembly recipe or frontend behavior is changed.

## API and ownership

`hrmb_context` contains one `hrmv_context` plus native-C string/float export callbacks and their user pointer. There is no singleton. `init/destroy`, `frame_enter/leave`, `declare`, `declare_put` and `get_copy` preserve the storage context and status. Use `hrmv_put_copy(&ctx.storage, ...)` for a separate assignment. Inputs are borrowed. Successful get returns compiler-owned output; failure leaves the caller's output unchanged.

Declare and put are separate operations. A new PRIVATE declaration creates NIL, PUBLIC creates .F. If the later put fails for allocation or unsupported type, that default remains readable and a later retry can succeed. Existing-value put remains transactional. `declare_put` is only a convenience for those two operations, not an atomic transaction. B2 must call declare and put explicitly.

Storage normalizes names once: validate the full original ASCII spelling, fold ASCII uppercase, truncate to 63, compare the full key including length. The bridge does not normalize again. Invalid non-ASCII names return BAD_NAME, not missing/1003. Get never declares. Frame exit restores shadowed bindings; independent contexts stay independent.

## Float representation policy

Heap float input must have exact tag `0x8000000000000005` and non-null payload pointing to 16 readable bytes `{bits,metadata}`. Storage allocates a raw-context 16-byte copy and frees it with the same allocator and exact size. Both words are opaque and preserved, including nonfinite patterns and full metadata. These are representation tests, not claims about source construction or Harbour rendering of all bit patterns. Caller owns pointer validity, as for strings.

Inline legacy input accepts only kind 5 with bits outside `0x00000000ffffff05` zero. Payload and full accepted tag are copied without allocation, including NaN/infinity/signed zero bit patterns. Other tags fail TYPE_UNSUPPORTED. Storage acceptance is intentionally broader than export.

Legacy export requires width bits 16..31 zero, decimals 0..255, and finite payload. Decimal 0 becomes 2. Width is 20 for positive values >9999999999.0 or negative values <-999999999.0, otherwise 10. Width-bearing or nonfinite inline export returns TYPE_UNSUPPORTED, never an invented BASE/1003. Heap export retains both full words. Every string/float get first obtains a raw storage copy, then calls the compiler callback, then frees the raw copy on every path. No raw heap cell is returned as a compiler allocation.

Callbacks use native C ABI on each target. They return a compiler-owned cell only on success, and own any partial resources on failure. The test adapters use explicit `sysv_abi` declarations and save/restore wrappers to call production internal helpers. There is no calling-convention cast. B2 must supply its own documented generated-code wrappers.

## Executable evidence

The review archive contains all raw stdout/stderr/rc and hashes, sources, emitted assembly, nm and objdump dumps. ELF and PE run under Linux and Wine respectively; this is not a native-Windows run.

- Fake-pool harness: exact pointer/size allocator records for separate raw and compiler pools, heap bit/meta ownership, source released before get, get/export allocation failure, unchanged output, strings with embedded NUL, case/prefix/truncation, shadow/restore, two contexts, supported scalars, invalid tags, legacy decimals 0..255, opaque heap/inline payloads, missing get without declaration, C12 default-after-failure/retry, new-binding heap allocation failures at both steps, transactional old heap value on failure, declaration allocation failure. 11 output lines match ELF/PE; raw/compiler counters reach zero.
- Prior storage regression against extended core: 4615 allocations and frees, zero live bytes on both targets; original semantic suite also raw-exact across targets. Kind 5 is no longer in its unsupported-tag loop; all other original gates retained.
- Production-helper harness: bridge get -> `hbc_float_new` -> `hbc_float_unpack` -> `hbc_str_f64`; real string allocation/free too. All production helper bodies remain byte-for-byte identical to compiler emission. Only unused program entry is renamed, wrappers appended. `identity-check.json`, `symbols-*`, `objdump-*-callchain.txt`, and `*-codegen-Str-fragment.s` prove identity and call sites.
- Metadata render: heap dec4 -> 3.5000, heap anchor -> 5.00, legacy dec0 -> default2 -> 5.00, legacy dec4 -> 3.5000. Exact four raw lines match official Harbour 694428e1c12f726675b19324d62167fa77d68185 ELF/PE output, including nine spaces. Official fixture uses literal floats to supply a rendering oracle; it does not pretend to construct inline legacy ABI values.
- Legacy decoder cross-check: seven boundary patterns times 256 decimals, compare exported metadata with the actual production unpack helper. Includes signed zero and exact/next-representable positive and negative width thresholds.
- ABI gate: real native callback nested into production heap constructor, RBX/R12-R15 sentinels on both targets, RDI/RSI and XMM6-XMM15 on PE, observed native entry alignment and writes to all 32 Win64 shadow bytes. Separate constructor wrapper gate calls with both caller stack parities and checks exact stack restoration.
- ASAN+UBSAN with leak detection: fake-pool suite, exit 0 and empty stderr. No sanitizer claim for production assembly.

The render is explicitly a C harness, not PRG `Str(binding_float)`: BASE frontend rejects Str(Dyn), at src/hbc.rs:15571-15577. The actual generated Str(F64) call target is `hbc_str_f64`; neither printf nor a replacement formatter is used for the value. B2 must add PRG-level Str(binding_float), including the currently rejected case.

Two test discoveries are recorded, not relabeled as initial passes: the guessed spacing expectation was corrected against independent official raw output (`expected-correction.diff`); the positive legacy threshold was corrected after the real decoder detected the interval between 9999999999.0 and 1e10. Production was not changed to fit a guessed expected.

## Reproduction

From this review archive, set HB_ORACLE_CORE to the official Harbour tree, optionally override HB_CCW/HB_ASW/HB_NMW/HB_ODW/HB_WINE and WINEPREFIX, then run `bash reproduce.sh`. The defaults name the local tools used for this capture. Setting HB_ORACLE_CORE rebuilds and reruns the official ELF/PE oracle. Without it the script explicitly reports the skipped rebuild and compares the included raw oracle.

The emitted `real/linux.s` and `real/windows.s` came from the supplied BASE compiler SHA256 6f1a157036197f22564dc4943e39ae452242db59325c0baad236ad71a1b3d294, using real/template.prg and `hbc input output --target=linux|windows`. They are included as evidence only, not committed as new product blobs. `reproduce.sh` regenerates wrappers and assembly ABI gates, rebuilds all C/assembly gates, rechecks helper identity, captures nm/objdump, compares all raw outputs and sanitizer stderr.

After applying CHANGES.patch to BASE, repository reproduction is `python3 tests/memvar/ownership-bridge/check.py --compiler /path/to/hbc --output /new/output-dir` with the same environment. That route regenerates production emission with the supplied compiler. The compiler is not embedded in the archive. The compiler-re-emission route was syntax checked but not rerun after its binary was removed for disk space. The applied-patch reproduction route was also run with `--emitted-dir /path/to/archive/real`, reusing the included production emission, rebuilding and executing the complete final recipe from patched source bytes. No fresh compiler-build or re-emission claim is made.

## Limits and B2 boundary

B1 does not fix the flat M0 table, codegen string-name bug, scalar lowering, eager evaluator lookup/folding or runtime tag9 provenance. It adds the approved bridge needed to replace that path, not a substitute flat-table repair. No F1-F7 evaluator/PRG gate is claimed complete here.

B2 resumes with scoped context/frame wiring, real MemvarSet lowering, complete parse -> literal-provenance fold -> runtime evaluation, scratch ownership on every path, F1-F7 and the full mixed-expression matrix. Include PRG Str(binding_float), exact/inexact/zero literal versus MEMVAR division, overflow, string comparisons, both-side errors, constant AND/OR elimination, dynamic short circuit, nested macros, syntax after missing name, explicit M-> MEMVAR-only semantics, shadowing, m1-values and terminal fatal suite. Original diagnostic spelling stays evaluator-owned. RELEASE ALL/masks, __mvSetBase, non-ASCII codepage semantics, field precedence, ErrorBlock/recovery and unmeasured types remain named limits.

C5 remains a separate prerequisite decision for B2. f13158c6abd2d006294c6ee604813928c01fc9a0 fixes terminal channel/format, explicitly not recovery. This unit neither reopens that terminal fix nor claims recoverability. Parent/owner ruling is still required before B2. The obsolete hrc_macro_set comment/path and movswl opcode 0xBF gate belong in B2. Any future changed generated blob must ship with generator, assembly and recipe/hash in the same unit.
