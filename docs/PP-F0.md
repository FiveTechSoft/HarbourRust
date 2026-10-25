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
  MACRO NAMES ARE CASE-SENSITIVE everywhere (verified with adversarial
  probes a05/a06): `#define MiXeD 5` does NOT expand a use of `mixed`
  (runtime BASE/1003), and `#ifdef LOWER` is false when only `lower` is
  defined. Our engine matches this: directive lookup ignores case, macro
  names are stored and matched exactly.
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

## Adversarial round (2026-10-25, second batch)

Probes c01-c04, a01-a06 (23 -> 30 total executed):
- `#command SHOW <x> AND <y> => QOut( <x> + <y> )` works (15); `#translate
  DOUBLE( <x> ) => ( <x> * 2 )` works (42); `#xcommand` works; commands can
  expand through other commands (chained, 4).
- Circularity (`#define LOOP LOOP`) is rejected by Harbour (E0020); our
  engine rejects by expansion-depth cap - equivalent rejection, different
  mechanism and message (registered, not claimed identical).
- Forward references expand at use time in both (`42`).
- Empty-body `#define` is accepted by both.
- Macro-name case sensitivity (above) was found in this round and fixed in
  our engine the same day; the test battery stayed 84/84.
- F3a landed (scoped): #command / #xcommand (full-line, literal words +
  <param> captures, chaining) and #translate in call form (inline, via the
  function-like-define machinery). Behavioural basis: probes c01-c09
  (keyword case-insensitivity, capture-until-literal, whole strings,
  chaining, incomplete-pattern rejection). Scoped OUT: [...] optionals,
  list captures, match markers, non-call translate forms, token pasting.
- Still unprobed: parameter-substitution case sensitivity in function-like
  defines, token pasting.

## F3b round (2026-10-25, third batch)

Probes a07, b01-b03 (30 -> 34 total executed):
- Parameter substitution in function-like defines is case-SENSITIVE, same
  as macro names (a07: `#define F(x) X + 1` leaves X unsubstituted;
  Harbour fails at runtime with BASE/1003). Our engine was case-insensitive
  here - fixed the same day, regression test t88.
- Optional clauses [ ... ] work in Harbour (b01) and list captures
  <x,...> work (b02). F3b landed (scoped): both, with the result-side
  insertion marker being the plain <x> form - Harbour rejects <x,...> in
  the result with E0009, and its own std.ch inserts lists via the plain
  marker (`#command ? [<explist,...>] => QOut( <explist> )`); our engine
  does the same (behavioural reference, no code copied).
- Token pasting (##): b03 only checked acceptance (PASTE never used).
  Follow-up probes: `a ## b` inside a function-like define FAILS at use
  (E0030, b04); `<n>##<i>` attached in a #command result also fails at
  use (E0030, b10c); spaced `? <a> ## <b>` compiles but produced empty
  output (b10/b10b) - whatever Harbour does here, it is NOT C-style
  token pasting and the semantics remain unclear. NOT implemented.

## Match-marker / token-paste round (2026-10-25, fourth batch)

Probes b04-b10c (34 -> 42 total executed):
- Match markers in this Harbour build (3.2.1dev r2610242111): <x> and
  <x,...> accepted, [...] optionals accepted including an optional list
  group [<x,...>] (b09: SHOW 1, 2 prints both; bare SHOW prints empty).
  <(x)> requires a PARENTHESIZED expression in the source (b14/b16:
  unparenthesized use errors E0030) and captures its inner tokens; in
  the result, <x> inserts them plain and <(x)> re-parenthesized
  (b15/b17). IMPLEMENTED scoped the same day (t91-t93).
  Optional groups NEST (b18: [TO <y> [BY <z>]] works at all three
  depths); the matcher is recursive like Harbour's behaviour.
  IMPLEMENTED (t94).
  <"x"> and <#x> are REJECTED (E0010 "Bad match marker") in both
  #command and #translate (b05, b05b, b06, b08) - NOT implemented.
- ## : see above - not C-style pasting; unimplemented.

Provenance note (corrected): this file records BEHAVIOURAL probes against
the Harbour binaries, and - stated where it happens - consultation of
Harbour's own .ch header rules (std.ch) as existing specification (e.g.
the plain <x> result marker for list insertion in F3b). No Harbour
implementation code (C or .ch bodies) is copied or translated into this
MIT project; reading published rules/headers to learn behaviour is
recorded, not denied.

- Non-call #translate forms: Harbour applies them at statement start
  (b19/b20 work; b21 inline-in-expression errors E0030). IMPLEMENTED
  scoped the same day via the command machinery (t95/t96). Harbour also
  applies them after its own `?` command through std.ch chaining; this
  PoC does not emulate that indirect path (scoped difference).
- Still scoped OUT: rejected marker forms (<"x">, <#x>), token
  pasting. No claim of general #command/#translate compatibility.
