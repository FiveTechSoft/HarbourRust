# Dyn arguments widen scalar parameters

A call site that passes a tagged-union (Dyn) value records Dyn argument
evidence for that parameter. The inference fixpoint merges it like the other
argument evidence: an integer, logical, string or float pin of the parameter
(from its body or from other call sites) widens to Dyn, because Harbour
retypes the parameter per call.

Before this, `f(x)` with `x := y % 19` (y untyped, so x holds a float) and a
second call `f(1)` pinned `b` as an integer; the boundary converted the Dyn
argument with the integer-only helper and the program stopped with
`Type error: NIL used as a number`. Harbour prints the call's result.

Not changed:

- A Dyn argument against an array-view, array or object pin keeps the
  existing call-site contract (the boundary checks the tag).
- Passing the shared module array keeps its named rejection (probe p6).
- Arithmetic on the widened parameter (`return b + 1` with a float in `b`)
  still stops with the same runtime type error, now inside the callee: Dyn
  arithmetic in a return expression only keeps float kinds in the opted-in
  functions. Registered limit, outside this increment.

`programs/*.out` are Harbour 3.2 outputs measured on Windows; `check.py`
compares them with hbc on the host target.
