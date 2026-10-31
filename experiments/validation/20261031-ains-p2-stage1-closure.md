# ains P2 stage 1 closure record, 31Oct 21:51 CET

Independent review of e7d211c7 (agent-01M69TS15RVXCW7413WKGJXYRT):
FAVORABLE within the declared scope. Stage 1 = Dyn-held scalar-cell
arrays on bare LOCALs: literal assign, reassign, cell read/mutate,
ValType/Len/HB_ISARRAY, whole-var empty print, read-only AView bridge,
plus the five escape closures of e7d211c7. NOT validated / NOT claimed:
general Dyn array params/returns, nested cells, AClone, mutating
builtins over Dyn owners, Harbour alias compatibility (registered rc1
differential instead), independent full-battery repeat (not run, by
instruction), pre-fix Wine behavior (never observed), binary-hash
equality of the reviewer rebuild (source identity + codegen equivalence
confirmed instead: rebuilt .s identical modulo embedded paths).

## Verified independently (own compile+run, raw rc/bytes, Linux + Wine 6.0.3)
- return of a Dyn-held array: rc1 registered with callstack, no SIGSEGV,
  bytes == writer evidence, Wine == Linux.
- Dyn owner to a normal param: same.
- alias Dyn<-Dyn: rc1 at the copy line, clean stderr under the
  instrumented registry (no free/transfer before the guard).
- self-root store index: static rejection.
- output freeze: static rejection, order-independent, `??` covered;
  borrow without mutation and post-print reassign work (freeze scoped to
  the statement), other-variable assign not falsely rejected.
- Ownership/cleanup: fresh memcheck probes balance 0 (reassign in
  branch+loop, array->string, early return); hbc_dfree verbatim at all
  six reassign/epilogue call sites; bridge guard before the -8(DATA)
  read, 24-byte caller header, byte-exact both OS.
- Stage-1 limits hold as clean compile rejections: nested (r2/r9),
  computed items (r7), AClone (r10), x := f(x) (r5). Scalars/strings
  preserved (r1/r3/r4/r8 oracles byte-exact, t1510/t1512/m1 exact).

## Claim corrections recorded at closure
1. Call-mediated mutation in output statements is closed STATICALLY:
   a callee writing t[i] := forces a typed-array signature and a Dyn
   owner argument is compile-rejected; `@` on Dyn is statically
   rejected; a by-ref-only-assigned parameter is not inferable, also
   rejected. The writer's interim claim ("covered by the runtime param
   guard") is superseded - the runtime guard remains as defense for the
   plain pass-through shape only. Verified: f(x[2], (x:=1)) prints
   canary (boundary clone, no UAF); f((x:=1), x[2]) is rc1 clean.
2. The type_expr self-root READ guard added in e7d211c7 is NOT
   independently exercised: broader guards (output freeze, cell-store
   rejection) fire first in every expressible probe. It stands as
   defense in depth; named limit, not a validated rejection path.
3. Manifest posx expected strings lack the final newline the programs
   emit: cosmetic encoding artifact of the manifest, not a behavior
   difference.

## Reviewer coverage (their count)
10 stage-1 fixtures + 10 r1-r10 oracles + ~15 fresh adversarial probes,
raw rc/bytes both OS. Reviewer evidence tar pending delivery at this
writing; Wine occupancy by the reviewer pending their release
confirmation.

## Next
Stage 2 design contrast (updated note 21:49: ASize realloc-by-copy
keeping live==cap with zero new runtime helpers; nested-cell print
oracles captured; share/RC stays outside pending the user's decision).
No implementation before contrast.
