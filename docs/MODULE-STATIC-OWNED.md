# Module STATIC S2: fixed logical and owned string

Base: 6c478b127d56811838d31f2ca0e59253d8cc1796. S1's i64 route stays intact. The S1 document describes that historical increment; this document owns the new logical/string boundary.

## Representation and lifetime

An explicit folded logical or string constant may now initialize a module STATIC. No general function-local STATIC widening is added. Logical slots use an eight-byte value behind the existing persistent address; the extra word is reserved, not an integer display contract. Reads are logical, not integers. String slots hold an owned pointer and length. They start zeroed in data and get one copy of their literal before any INIT hook. All function/method aliases use the same canonical address. The initializer and final release are deduplicated per canonical label.

Replacing a string constructs the complete new RHS first, then frees the old owner and installs the new pointer. Reading into a local, returning a value, passing by value to a typed/Dyn function and assigning from another module string hand the recipient an owned copy; the persistent slot is not moved out or nulled. Self-assignment is a no-op. Existing @string lowering may replace the pointee, and the persistent slot stays the owner. Copies made for locals are explicitly heap-escaping in the arena analysis so the ordinary epilogue releases them.

On normal process exit, persistent string slots are cleared and released once, then the string cache and arena are flushed by the existing exit path. A caught exception does not roll back an already completed module assignment. Uncaught fatal process exit still follows the existing fail-fast path; this increment does not promise exception-safe teardown of every live frame or a new process-wide unwind protocol.

## Named limits

- Fixed type only. NIL, float, Date, array and hash module initializers still fail, and a logical/string slot cannot change to another type.
- Logical @arguments remain rejected: the old reference ABI is i64-specific. New logical/string storage with threads is rejected rather than allowing shared-owner races.
- Owned module strings cannot enter containers, inline assignments/inc, computed receivers, value-selecting IIF/Eval or sequence-expression ownership routes in this increment.
- A statement that combines a persistent string borrow with a potentially mutating call is rejected, including output-item mutation and later-argument mutation. The caller can split the effects into statements. Pure measured string observers are allowed. This is deliberately stricter than Harbour and not an alias-safety claim for all expression forms.
- Branch/catch shadows and explicit MEMVAR overlap remain named limits. Tests now include a counter inside TRY and a catch binding with the module name, as requested.
- No arrays, generic variants, general captures, new thread synchronization or multi-file linkage. Native Linux/PE lowering only; no new LLVM/Mach-O support or certification.

## Oracle dialect and test provenance

All tests are synthetic, with no Harbour implementation or external-contribution source copied. The same .prg source is supplied to both compilers. For exception probes, Harbour gets -dHARBOUR_ORACLE, which selects a test-local spelling shim: TRY/CATCH/ENDTRY become BEGIN SEQUENCE/RECOVER USING/END SEQUENCE; the native path uses its existing TRY/CATCH/END parser. No exception runtime is shared. This dialect shim is recorded, not silently called identical preprocessing.

The runner uses fresh Harbour GTSTD on Linux and PE-Wine, exact stdout/stderr/exit and --instrument for the candidate. The root manifest receives raw captured target bytes with -text attributes. The old S1 logical/string negative sources are removed because they are now supported; the remaining initializer diagnostic and S1 runner are updated, not left with stale expectations.

## Final memory checks

check_memory.py emits instrumented unpruned assembly, inserts a test-only hb_memcheck-equivalent zero assertion after persistent cleanup, string-cache flush and arena flush, assembles it externally and compares the original oracle streams. A nonzero balance exits 99. This is an independent test hook, not a hidden compiler feature.

13 non-class programs x two targets pass that final zero assertion, including local copy/replacement, alias copy, by-value/@calls, INIT, repeated replacement and a caught exception. The class method program is intentionally not included in the zero assertion: its object runtime retains the existing chunk/template pool. Measured Linux controls with the S1 compiler and S2 compiler, both without persistent payloads, end with balance 2; the S2 owned-module method case also ends with balance 2 after persistent cleanup. These controls support no added balance for this case, not a zero-allocation claim or a proof of every class lifecycle. All class-method output bytes still compare to Harbour on both targets.

## Gates on the final compiler

SHA256: d2b6fc7d31bf00a32245a6d6103836f5f5b2b591a260a55cd894446eff6bf775.
- S2: 14 positive sources x two targets = 28 exact oracle comparisons; 10 Harbour-valid negatives x two = 20 named rejections.
- Final whole-process memory zero: 13 sources x two targets = 26 assertions, as scoped above.
- S1: 32 exact positive comparisons plus 26 remaining negative checks.
- FILE: 56/56, fresh Linux/PE-Wine, internal/external engines.
- Classes: 42/42 fresh Linux; PE object separators: 3/3 fixtures.
- Names/Date: 28 exact positives plus 10 negative checks.
- Unit tests: 51 passed, no failures.
- Compile-only PE manifest CI: 1783 PASS, 21 unchanged known mismatches, no unexpected failures.

No full root runtime battery, native Windows executor, concurrency test or Mach-O execution was run here. The original failed/intermediate candidates are not the final gates. Any change to compiler code requires new gates on its exact hash.
