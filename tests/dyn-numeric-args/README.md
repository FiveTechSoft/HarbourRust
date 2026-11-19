# dyn-numeric-args

Numeric builtins `Str Int Abs Max Min Round Sqrt Mod` and the operator `%` with a Dyn operand (a float or integer held in a Dyn slot), and Dyn
arithmetic (`a + 1`, `a * b`) used as an argument of those builtins or of a user function with a Dyn parameter.

Measured on the compiler before this change (main `db6d31f8`, 18 November 2026): these forms compiled and then stopped at run time with
"Type error: NIL used as a number" when the argument was a Dyn arithmetic expression holding a float (Dyn arithmetic was only evaluated by kind at
print, assignment and condition consumers), or were rejected by name when the argument was a plain Dyn. The oracle (Harbour 3.2.1dev) runs all of them.

Now the argument is marked like a print consumer and evaluated by kind. `Min`/`Max` with a Dyn side return a Dyn, compare as integers when both are
integers and as doubles otherwise (the first operand wins a tie), and release the first operand if the second throws under TRY. `Int` of an integer tag is
exact; a float payload truncates toward zero. Non-numbers still raise "NIL used as a number" in the same place as the oracle's error rows.

## Checks (`check.py`)
1. `programs/values.prg`, `programs/throws.prg`, `programs/effects.prg`, `programs/strfx.prg` and `programs/moveargs.prg`: stdout byte-identical to
   the external oracle on ELF internal, ELF `--external-as` and PE under Wine (CRLF). `moveargs.prg` passes a `+` expression whose nested call moves
   a heap local into a Dyn parameter (plain and parenthesized): the route-marking walk types the arithmetic children speculatively and restores
   their moved flags, so the real typing pass sees them unmoved (regression caught by `tests/nested-call-move` on the first cut of this change). `effects.prg` counts argument evaluations with a STATIC: with an invalid Dyn first
   argument of `Mod`, `Round` or `%`, or of `Str` with a width, the second argument still runs first (Harbour evaluates every argument before
   validating the first one's type), a throwing second argument makes the catch fire only after it ran, and the type error is catchable. The
   counter proves entry and evaluation order only; the IDENTITY of the caught error is not audited by this gate (the subset's generic CATCH binds
   no error object).
2. `mem/loop.prg`, N=1/500/1000, three targets, fourteen rounds (owned temporaries as arguments, throws on either side of Max/Min, NIL and string
   operand errors, the evaluation-order rows above): `hb_memcheck` pending 0, the Dyn operand unchanged, hit and callee entry counters.

## Limits (not covered, measured)
- `Left`/`PadL` with a Dyn float count: rejected at compile time (not supported in this increment). `Str`'s width/dec as a Dyn value is also rejected at compile time (the oracle accepts a Dyn float width).
- A throwing width/dec of `Str` inside a `try` trips a pre-existing frame mismatch of the base compiler (separate finding), so it is not gated here; only its non-throwing order is.
- A user-function parameter used in arithmetic is inferred as an integer, so `RETURN x + 1` called with a float Dyn still ends in the run-time type error; `Id(3) + Id(a)` also failed before this change.
- `^` is not covered. `Round` keeps an integer number of decimals. `Max`/`Min` on logicals are unchanged. `Abs` of the minimum i64 is not specially handled.
- Separate findings on the base, not changed here: `Int(9007199254740993)` prints with a different width than the oracle; a `Str()` of a Dyn value followed by a `try` that catches a thrown error ends with "MEMVAR frame mismatch (M0)"; and a comparison or logical expression whose operand is an arithmetic expression containing a call that moves a heap local (`r := G( s ) + "y" == "ab!y"`) is rejected with "use of moved value" - the comparison arm of the checker types its operands twice, a pre-existing double-typing bug of the base (present on main `6b70b06b`), so comparison/logical variants of `moveargs.prg` are not gated here. `programs/throws.prg` is kept apart from `values.prg` because of the second one.
