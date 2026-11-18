# Parameters without type evidence

Contributed by Julio Ponce, MIT license. The fixed-point change (BYREF_PARAMS, DEFAULT_DYN, DEFAULT_ENABLED late phase) is his;
the S4 guard, the extra fixtures and the oracle gate are added here.

What it does: when the ordinary fixpoint ends with `cannot infer the type of parameter`, it runs again and gives those
parameters (and only those) the tagged Dyn slot, as Harbour does. A program that compiled before is unchanged, with one exception added in v7: in a program with classes, a call to a function that has a defaulted parameter now rejects (named compile error) any OTHER `@` or object-typed argument of that call, which compiled or failed differently before. Parameters that
some caller passes with `@` keep the rejection (their slot belongs to the caller).

S4 guard (added here): a parameter that reached Dyn only by default never receives the shared module array (STATIC array) or an alias
of it. The check runs in the call type check BEFORE the acceptance test, because once the parameter defaults to Dyn the argument
type agrees with it and would be accepted silently while Harbour aliases the one object (probe p6, deferred). Parameters that are
Dyn because of body evidence keep their previous behaviour.

Gate (`check.py`, 63 checks): `unused`, `forward`, `shared-element` are byte-identical to the external Harbour 3.2.1dev r2610242111
oracle (not Harbour 4) on Linux (ELF, internal and `--external-as`) and Windows (mingw oracle under Wine vs PE internal/external).
`forward-memory` uses `hb_memcheck`, which Harbour does not have: it is checked against `forward-memory.expected` ("pending 0"; CRLF on
Windows), i.e. a measurement of hbc, not an oracle comparison. `neg/` are named rejections on both targets with the expected diagnostic:
`shared-call-arg`, `shared-alias`, `shared-via-forwarder`, `shared-second-argument` (S4 diagnostic), `shared-byref` (existing @ rule),
`local-array` (existing flat dynamic-array rule), `other-arg-byref`, `other-arg-byref-first`, `other-arg-obj`, `other-arg-self-method` (see v7 below), `object-arg-discarded`, `object-arg-print`, `object-arg-multi`, `object-arg-local`, `object-arg-file`, `object-arg-return`, `object-arg-new` (object argument, new named rejection), `object-arg-byref`, `object-data-member`. `tests/module-static-array/check.py` keeps `call_arg` a rejection; only its expected
diagnostic changed from "cannot infer the type of parameter" to the S4 text, never to a positive.

Objects at the defaulted-Dyn boundary (review findings 2 to 5). A parameter that defaulted to Dyn (no body evidence of its type) is a conscious
delimitation of this cut: it never receives an object, and no ownership claim is made for it.
- Static: an argument whose type is an object (variable, call result such as `Ident(Mk())`, `K():New()`) is a named compile error
  "passing an object as argument N of `f` is outside the dynamic increment ..." (`neg/object-arg-*`). Probed first on the previous compiler with a
  fresh object per turn (N=1/500/1000, control with the call guarded out): a discarded call, `? Ident(o)`, a multi-item print, `LOCAL z := Ident(o)`
  in a loop and `FILE(Ident(o))` each retained one reference per turn (pending 4 and 8 at N=500/1000, control 0); raw probes in the package.
  `Ident(@o)` keeps its existing rejection (`neg/object-arg-byref`) and a DATA member holding an object is still the existing named rejection
  (`neg/object-data-member`), so no member can carry an object into the call.
- Runtime: a Dyn VALUE that holds an object (tag 13: a Dyn variable, a Dyn call result used directly, a value assigned from a call) passed to a
  defaulted-Dyn parameter is rejected before the callee starts, with the named runtime error "Object in untyped parameter" (a normal runtime error,
  catchable by TRY; uncaught it exits 1 like the other named runtime errors). The screen runs after every argument has been evaluated and pushed
  (the same order as the existing NIL-object protocol): casillas already materialized (cloned strings, floats, owned Dyn temporaries) are released,
  an owned temporary object is released, a borrowed object of the caller is never released, and the callee is not entered. An owned array or hash
  argument in the same call as such a Dyn argument is a named compile error (the screen could not release it). Parameters with body evidence and
  every call that does not pass a Dyn into a defaulted parameter are unchanged, except for the v7 rejection of `@` and object arguments described below; no ABI change.
- Fixtures `dynobj/*` (`dynobj-*` rows, N=1/500/1000, ELF and PE): Dyn variable, Dyn return as argument (owned temporary), a Dyn assigned from the call,
  and an earlier materialized string argument in either position. Each program creates fresh objects every turn, reads the surviving object AFTER new
  objects were created and written (7 + 11 + 13 per turn, so a premature free or reused block changes the sum) and requires `hits == N`, the exact
  sum and `pending 0`. `dynobj-ctl-*`: scalar, string, NIL, logical and float arguments are not rejected (hits 0). The previous compiler (v5, no runtime
  screen) fails all 18 rejecting rows.
- v7 surface cut (review of v6). In a call whose callee has a defaulted-Dyn parameter (programs with classes), any OTHER argument that is `@` or
  object-typed (including the Self of a method call, which is argument 1) is a named compile error (`neg/other-arg-*`), so the runtime screen only
  ever sees flat casillas (strings, floats, Dyn); the cleanup also skips a `@` or object casilla defensively. Probed first on v6
  (`raw-probes-v7-*`): `@` next to a Dyn argument ended in an internal assembler error (undefined `hbc_fn_two__br01`/`br10`), not a named error; a typed object
  argument next to a tag-13 Dyn argument (and Self of a method with a defaulted parameter) left one retained reference per turn (pending 4 and 8 at
  N=500/1000, control 0). v7 rejects them at compile time. No claim is made that every casilla is cleaned in every case.
- v8 (review of v7): the `@`/object guard now runs inside the argument loop and reuses the type already computed there (no second `type_expr`,
  so it publishes no extra moves). Controls `edge-ctl-nest1` / `edge-ctl-nest2` (a call with a defaulted parameter and a consumed owned string in
  the arguments, in two shapes) must still compile and run. Separately measured, NOT part of this increment: a nested call that consumes an owned
  string, `F(G(s), d)` with `G(s)` returning `s + "!"`, is rejected with "use of moved value `s`" ALSO by the main-tip compiler without any class or
  defaulted parameter in the program (`raw-probes-v8-nested-move/`, `m1.prg`), so it predates this package; it is left as is.
- Edge rows (`edge-sentinel`, `edge-uncaught`, ELF and PE): the callee body is not entered (a sentinel `ENTERED` is never printed; the parameters stay
  unevidenced), both argument orders and an omitted trailing argument are rejected under TRY, and an uncaught rejection exits 1 with the named error.
  A parameter that receives an omitted argument somewhere gets NIL evidence and is no longer a defaulted one, so it is outside this screen
  (the sentinel uses separate callees).
- Known limit, measured (`raw-probes-v7-laterthrow`): if a LATER argument of the same call throws during its evaluation, the existing exception path
  does not run this cleanup; an owned temporary object passed earlier in that call stays retained (pending 4 and 8 at N=500/1000; a borrowed one is
  released by its owner, pending 0). v7 does not close that case.
- What is measured is alive/dead and pending memory; there is no reference-count counter to read, so no claim is made about the absence of an
  extra release beyond these observations.

Limits: Wine, not native Windows. Arrays and hashes passed to a defaulted parameter keep their existing rejections. Parameters whose
only evidence arrives through a later round are covered by the fixpoint restart, not by a per-case proof beyond these fixtures.
