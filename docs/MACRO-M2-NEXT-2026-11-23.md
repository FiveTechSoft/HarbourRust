# M2 next unit: character-code builtins (Chr/Asc)

Design proposal only (2026-11-23). **Nothing here is implemented, measured or
published.** No builtin is added to the M2 dispatcher by this document; the work
below is a scoped plan that must pass the gates listed
before publication, and this session is not a verification environment.

See [M2 record](MACRO-M2-2026-11-16.md) and the roadmap item "Extend the
builtin catalog on the M2 dispatcher" for the context.

## Scope proposed

The first M2 trio (Upper/Lower/Round) covers the string-case and the numeric
rounding boundary of the precompiled / contextual scalar macro evaluator. The
natural next bounded unit is the **character-code pair `Chr` / `Asc`** (one
argument each, one helper each, the same three-file shape as the trio):

- `Chr(n)` — one integer argument → one one-byte string (the character code).
- `Asc(s)` — one string argument → the code of the first byte.

Rationale: the other scalar builtins (Str/Int/Abs/Max/Min/Round/Sqrt/Mod)
already have their own gates and would overlap the dyn-numeric-args coverage;
Chr/Asc sit at the same 1-argument, ASCII, owned-result boundary as Upper
and Lower, and both are the single-argument names most expected at the macro
boundary (Harbour accepts both in macro contexts).

Selection is a **proposal**, not a measurement; measured coverage and
dependencies must confirm nothing in the manifest leans on other shapes
first. If a different unit is selected, the acceptance shape below still
applies.

## Named limits of the proposed increment

- ASCII semantics only; no codepage/Unicode mapping. `Chr` of an integer
  outside the admitted range and `Asc` of an empty string are named
  stage limits, never silent clamp or wrap.
- The 64-argument cap and the M2 evaluation order (every argument, left to
  right, per the M2 record) stay unchanged; Chr/Asc are unary.
- The Round range gate is Round-specific; Chr/Asc have their own named range
  failures in the same style.
- Named unknown/unseen-name behavior is unchanged (named M2 limit after
  evaluating the surviving arguments, never a crash).
- `^`, locale/codepage behavior, and any Mach-O gate stay out of scope
  (same as the trio: no Mach-O execution gate was run for the trio).

## Files the increment would touch (shape, not a diff)

```
src/macro_call_shims.s                          # hrm_call: dispatch IDs 4,5 -> hbc_chr / hbc_asc
src/hbc.rs                                      # helpers hbc_chr / hbc_asc (ELF and PE sites) + dispatch/codegen sites
runtime/hrmacro.c                               # builtin_id (names[4]), evaluate_call validation, call_error names
runtime/hrmacro_embedded.c                      # included by the recipe (tests/generate_macro_asm.py)
generated/hrmacro.s (via the pinned recipe)     # regenerated; PE path needs the same toolchains as the trio
tests/macro/m2/{positive.py,limits.py,fatal-matrix.py,abi.py,pe-controls.py,mixed.prg,values.prg}
                                               # new rows per gate
docs/MACRO-M2-2026-11-16.md                    # a new dated record next to the trio's
```

## Evidence gates required before publication (repeat the trio's gates)

All of these are required and none can be run in this session (no oracle,
no Wine, no MinGW, no x86-64 execution host):

1. **Oracle gate**: same-source positive programs compiled and run against
   official Harbour (pin 694428e1c12f726675b19324d62167fa77d68185) and
   HarbourRust, stdout/stderr/rc byte-identical, normal and instrumented
   modes. value-like cases including empty strings and the admitted range
   boundaries.
2. **Arity/limit gate**: unary-only arity rejection and the named range
   failure for out-of-range `Chr` / empty `Asc` argument.
3. **Ordering gate**: unary argument evaluated exactly once, left to right,
   including a throwing argument, which must surface before any helper is
   entered (the argument is never silently swallowed).
4. **Ownership/balance gate**: owned-result transfer for `Chr`; argument
   drop rules matching the evaluator; `hb_memcheck` pending 0 after each
   positive (mirrors the mixed/values gates).
5. **ABI/host-fault gate**: 96 raw + 96 compiler-allocation injection steps per
   the M2 pattern (host fault harness) — the fatal callbacks must assert
   pools/scratch/frames/bindings zero, and ASAN+UBSAN must exit 0.
6. **Regression gate**: full manifest compiled/captured against BASE on ELF
   and PE, zero raw runtime/stdout/stderr regressions; known inherited
   mismatches keep their records (not blanket-green).
7. **Independent review** of the package by a second party before publication
   (the publication owner keeps the final base/hash check).

## Why it is not done here

This session has no oracle checkout, no MinGW/Wine runtime, no x86-64 execution
host, and no `--external-as`/MinGW recipe toolchain — every gate above is a
runtime gate. Adding the code without its evidence would publish a claim the
repository's own discipline forbids. The next session with an x86-64/Wine
environment can pick up this doc as the scoped starting point.

## Out of scope for this unit

- M2's later macro forms (M4): assignments and array/hash/codeblock literals,
  user-code calls, recoverable ErrorBlock/BREAK/RECOVER, thread context
  propagation — each needs its own design, same as the trio.
- General `Chr`/`Asc` at the Dyn argument level (the dyn-numeric-args gate
  covers the numeric builtins; character-code names at Dyn operand sites are
  a separate unit if wanted).
- A general `Desc`/`TransLit-like` character-set semantics argument.
