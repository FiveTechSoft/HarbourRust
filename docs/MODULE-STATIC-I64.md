# Module STATIC: first increment

Historical S1 contract. S2 logical/string expansion and its current limits are documented in MODULE-STATIC-OWNED.md.

## Contract and design

This increment starts from 4f801fdd. It adds one storage identity shared by functions, methods and startup hooks in a single preprocessed translation unit. It does not add a linker/module loader or a general dynamically typed persistent value.

Only declarations before the first function or method are accepted, with an explicit initializer that the existing parser folds to an i64 constant. Multiple names, negative constants and constant arithmetic use the existing LOCAL declaration parser. Duplicate module names fail before code generation. A declaration without an initializer is NIL in Harbour and is not supported here.

Each module variable receives an internal numeric slot label, not a user-visible global assembler name. A function that uses the variable receives an internal STATIC binding to that label. Existing function-local STATIC lowering supplies a borrowed address of the slot, not a copy of its value. The data label is emitted once. The existing 16-byte integer storage contract (payload plus numeric display metadata) is retained. INIT therefore sees the initialized slot before Main, and writes through a function, a method or an existing @i64 argument are visible to the other users.

Ordinary parameters, top-level LOCAL and top-level function-local STATIC with the same spelling shadow the module variable. Function-local STATIC keeps its old independent label. Block parameter shadowing is unchanged. Branch-local declaration shadows, catch binding shadows and explicit PRIVATE/PUBLIC/MEMVAR overlap are named limits rather than guessed bindings.

The alias and emission registries are compilation state and reset on parse. They do not exist in the generated executable. No heap allocation or destructor is added for these constant-i64 slots. Unreferenced slots have no side effects and need not be emitted. User names such as month do not become slot symbols, and ordinary builtin calls keep their existing resolution.

## Boundaries

- NIL, logical, float, Date, string, array and hash initializers remain named rejections for module storage. This does not remove their separate function-local routes.
- Dynamic type replacement, numeric promotion, overflow beyond fixed i64, STATIC loop counters and general captured module variables are not newly supported. Existing checked-i64 and capture guards remain in force.
- STATIC declarations inside INIT are still rejected. Reading/writing a module slot from INIT is different and is supported.
- No new cross-thread synchronization, atomicity, module loader or multi-file linkage is promised. Existing thread/borrow boundaries still apply.
- LLVM scalar keeps its existing STATIC-node rejection. Execution gates here cover native Linux/PE; Mach-O is not validated in this increment.
- No external contribution implementation or Harbour body was copied. All probes are synthetic; Harbour is an external oracle.

## Validation plan

Run tests/module-static/check.py with --compiler, --hbmk2, --output and optional --wine. It compiles the same positive sources with fresh Harbour for each target, then compares stdout, stderr and exit byte for byte. Negatives distinguish Harbour-invalid sources (duplicate, late declaration, branch LOCAL, runtime Date initializer) from valid Harbour shapes outside this increment. Do not count those invalid sources as missing HBC compatibility. The root manifest carries copied fresh-oracle fixtures and named negatives so CI also sees this increment.

Required gates before publication: module identity/shadow/byref/method/INIT/recursion positives on Linux and PE; FILE 56; classes 42; object separator PE 3; names/Date existing probes; compile-only manifest CI and unit tests. Linux-hosted Wine is not native Windows validation. No snapshot replacement or push without review.

## Final candidate evidence

Compiler SHA256: 3b0675ef913034048fd017ded0f31ce81ed620a01dce63383740072b79c862d3.
- Module probes: 16 positives x two targets = 32 raw-exact Harbour comparisons; 15 negatives x two = 30 correct named rejections. Four negative sources are also rejected by Harbour, 11 are valid Harbour outside this increment.
- FILE 56/56 with fresh Harbour Linux/PE-Wine and both assembler routes.
- Classes 42/42 with fresh Harbour Linux.
- Windows object separators 3/3 captured fixtures.
- Names/Date 28 raw-exact positives plus 10 negative checks.
- Unit tests: 49 passed, 0 failed.
- Compile-only PE CI manifest: 1761 PASS, 21 unchanged known mismatches, 0 unexpected failures.

Self-review added a module-specific counter guard before binding methods: the old driver validates function-local STATIC counters before methods join the function set. A method counter could otherwise bypass that named boundary. method_loop is a fresh Harbour-valid negative that now verifies the same rejection on both targets. Existing unrelated method-local STATIC behavior is not expanded or repaired here.

No full root runtime battery, native Windows executor, stress/concurrency certification or Mach-O run is claimed. The package includes exact stdout/stderr/exit and hashes; compilation success alone is not counted as a functional pass.
