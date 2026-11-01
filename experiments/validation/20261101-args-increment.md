# Args increment (approved contract 2026-11-01 01:27:34 CET)

Scope (contract A1-A6, consolidated 01:27:07, reviewer OK 01:27:34):
- A1: empty Argument -> NIL in EVERY position of EVERY call (leading,
  middle, trailing); the checker marks nil_ev[i] for explicit NIL slots
  exactly like trailing omission; the fixpoint forces the parameter to
  the tagged union (I64/Bool/Str -> Dyn; F64/array/hash/block keep the
  named error). Replaces the iif-only parse special case.
- A2: Expr::Set inline assignment as an argument via the existing
  parexpr/assign_expr path (integer/logical only; ro/byref/moved guards
  untouched). The entry gate is Ident + `:=`: IdxCompound (a[i] += e)
  and store-index (a[i] := e) as the ARGUMENT fall through to or_expr
  and stay named parse rejections (t1538/t1540). The right side cuts
  at the argument comma.
- A3: no hb_DefaultValue/PCount in fixtures (ValType is implemented).
- A4: no builtin default extension. A5: @x + assign-inline in the same
  list stays the conservative documented rejection. A6: send/DO WITH out.

Source: src/hbc.rs sha256 2b9a5d6ba060740168d6646a4b1e134ecff65ac6a6d41fc127de6154b7c9419f
Binary (rustc 1.99.1, `rustc -O src/hbc.rs -o hbc`): sha256 2aacc324e35dbeb1af71e99fc590f227b56a9f449b997759af7122c63a4439ec

Gate: tests/run_battery.sh strict, Linux+Wine, runID 20261101-013313-argsinc2
- 1529 PASS / 0 FAIL, no retries; manifest sha256 fae2c9a8111305d8635377781e14c6f9a80054c49cc64cc6d4cbb530db4055c6
- header: gen/run-20261101-013313-argsinc2.header (run anchors at start)

Oracle fixtures (expected bytes = semantic extract of reference-Harbour
runs of the SAME fixture sources, Harbour 3.2.1dev r2610242111, console):
- t1536_argomit_pos: source = probe p3 verbatim; F(,2)/F(1,)/F(,) ->
  |U|N| / |N|U| / |U|U| (matches oracle run3).
- t1537_arginline_pos: probe p4 with hb_DefaultValue replaced by plain
  addition (A3); 34 / 22 left-to-right once-each (matches oracle run4),
  plus byref order variant 6 / 3, both oracle-verified.
- t1539_argomit_bodyi64_pos: A1 body-pin case; oracle: -1/3, 2/-1,
  -1/-1, 2/3.
- t1538/t1540: named parse rejections for index/compound-assign targets
  in argument position.

Behavior changes (contract-mandated, oracle-verified against the
reference build):
- t718: explicit NIL to an integer-pinned parameter now routes through
  Dyn and prints .F. - matches Harbour hk271 exactly; the old
  extraction-failure divergence is gone (posx exit-1 -> pos).
- t719: same for a string-pinned parameter, NIL == "ab" is .F. -
  matches hk272 (neg -> pos).
- t994: iif(NIL,...) stays a named COMPILE rejection ("`iif` condition
  must be logical"); Harbour itself rejects it at compile time (E0038).
- t996: f(,) now parses as two NIL arguments and hits the extra-argument
  rejection ("`f` takes 1 argument(s), got 2").

Not in this increment: Dyn float tag (pending), Stage 3 (nested/AClone),
GT scope, send/DO WITH, hb_DefaultValue/PCount.
