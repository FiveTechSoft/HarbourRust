# Mixed scalar returns, ordinary Linux

MIT implementation. Harbour is an external executable oracle, never linked or copied.

Extends return unification only for Bool/Str/StrOwn with Dyn, using the existing
rax tag / rdx payload ABI. Tags: NIL=1, logical=3, owned string=4.
Owned temporary/local strings move; rodata strings copy; caller Dyn cleanup is
unchanged. Byref-specialized labels resolve exact function names first, then
strip only a final nonempty binary __br mask. No ABI growth.

New cases are rejected outside ordinary Linux, in thread-family programs and
in PRIVATE/PUBLIC/macro contexts. This is a compile-time limitation, not oracle
parity. Direct byref string returns remain an existing inference limitation;
computed strings through byref parameters are tested.

Run each Python gate with --help for arguments:
- check.py: 19 sources, 38 exact internal/external oracle comparisons, base rejects.
- catch.py: 4 catch/ownership shapes x2 modes, TRY converted only in oracle driver
  to Harbour BEGIN SEQUENCE WITH {|o| Break(o)} / RECOVER / END SEQUENCE.
- safety.py: 3 instrumented modes, repeated returns/cache reuse/byref string
  lifetime checks, 100 warmup + 10000 measured iterations, zero allocation delta.
  This does not claim oracle parity for compiler-specific hb_memcheck().
- limits.py: 10 memvar/macro limits with external oracle controls and 4 profile
  limits; every rejected program stays unexecuted.
- originals.py: 7 external pinned hbnf files unchanged through own include-only
  drivers, 14 exact pairs for the listed valid callshapes, no invalid-path claim.
- mutants.py: 3 Rust-valid mutants must compile/run0 and differ from valid
  oracle-equal controls. Build failures, timeouts or signals never count.
- guard_selftest.py: 4 fake rustc proxies demonstrate fail-closed mutant gates;
  proxies are not product mutants.

Review V2: one effective signature drives ALL Ret branches (I64/F64 and
StrOwn too). review.py adds12numeric byref sources/24exact pairs,6mixed
CATCH+FINALLY compile limits/12rejections and4prior numeric FINALLY omissions
with8base-identical controls. Only newly admitted mixed string/logical Dyn
functions with such a return reject. Numeric base behavior is unchanged and
still omits FINALLY; repairing that prior defect is out of this increment.
