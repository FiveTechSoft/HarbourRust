# PP-F0: preprocessor behavioral baseline (observed, black-box)

Goal of our own preprocessor (MIT, written from scratch in Rust): support the
directive surface Harbour programs need, matching OBSERVED behaviour. This
document records only what we measured by feeding probe programs to the
Harbour toolchain (hbmk2, harbour/core @ 694428e1, built locally) and
watching what compiles, what is rejected, and what prints. The probes are
our own small programs, designed and executed purely by observed behaviour;
no Harbour code was copied or translated into this document or into the
implementation that follows it. (During the earlier licence evaluation the
GPL notices of Harbour's src/pp files were read; that is a different,
disclosed activity - this specification is behavioural, not a description
of their implementation.)

Probe set: /tmp/pp_probe, 23 probes executed (p01-p18, q13, q14, q18-q20;
each <20 lines, kept locally). q13/q14/q18 supersede p13/p14/p18, whose
test statements sat outside a function and therefore did not run.

## Observed to WORK (accepted, output verified)

- `#define X 42` (object-like, numeric): `? X` prints 42.
- `#define GREET "hola"` (object-like, string): prints hola.
- `#define F(x) x + 1` (function-like with parameter): `? F(2)` prints 3.
- `#undef B` removes a definition.
- `#ifdef` / `#ifndef` / `#else` / `#endif`, nested correctly.
- `#elif V == 2` exists and selects correctly.
- `#if V == 2` works; comparisons with `>`, `<` work; `.and.` combines them.
- `#if defined(Q)` / `#if defined(NOPE)` work.
- `#include "defs.ch"` includes a sibling file; its defines apply.
- `#error custom text` aborts compilation with an error.
- Directives are case-insensitive: `#DEFINE`, `#IfDef`, `#EnDiF` accepted.
- Redefinition without #undef is accepted; the last definition wins.
- Predefined `__HARBOUR__` exists; prints 197121 (version-encoded integer).
- `#command SAY <x> => QOut( <x> )` works: user-defined commands translate.

## Observed REJECTED / limited

- `#if V = 1` (single `=`): E0025 "Error in #if expression". Use `==`.
- The `&` macro operator is a RUNTIME feature over memvars, not a
  preprocessor one: with locals it fails at runtime (BASE/1003). Out of
  preprocessor scope.
- Statements outside any function are silently not executed (observed while
  probing); unrelated to the PP, noted to keep probes honest.

## Proposed increments (own implementation, no code from Harbour)

- F1 (minimal, serves hbc programs): object-like `#define`, `#undef`,
  `#ifdef`/`#ifndef`/`#else`/`#endif`, `#elif`, `#if` with `==`, relational
  operators, `.and.`/`.or.`/`.not.`, `defined()`, `#include`, `#error`;
  case-insensitive directive names; last-wins redefinition.
- F2: function-like `#define` (observed working in Harbour; useful).
- F3: `#command`/`#xcommand`/`#translate` (large; gates Harbour's own .ch
  headers). Needs its own behavioural round before any commitment.
- Out of scope: `&` macro operator (runtime memvar feature), `#pragma`.

Version identity: we do NOT predefine `__HARBOUR__` with Harbour's value
(197121) - we are not Harbour, and that value would claim a compatibility
we have not earned. Whether and when our own identity/version symbol
appears is deferred until a real compatibility need arises; it does not
block F1.
