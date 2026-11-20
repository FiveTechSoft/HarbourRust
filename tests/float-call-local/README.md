# Integer LOCAL receiving a proven F64 call

Own MIT probes, with Harbour only as an external executable oracle.

The storage hint is limited to names with an integer literal store in the same
function and a direct call whose current signature returns F64, or Seconds().
It uses the existing ordinary-Linux/no-threads profile. It does not run the type
checker speculatively, change numeric codegen, or widen every F64 local.

`check.py`: ten own sources, both assemblers, exact rc/stdout/stderr. Includes
forward declaration, integer and decimal result branches, integer metadata,
one evaluation, and a no-integer-origin control. Seconds is tested with stable
type/range predicates rather than comparing two independent clock readings.

`safety.py`: three instrumented lifetime modes, five excluded profiles and two
named limits. Warmup then1000 normal stores and1000 RHS catches per Work with
net allocation delta0. These are not Harbour error-semantics comparisons.
`mutants.py`: the compiler must build successfully, then the PRG must reject
when the isolated hint is removed. This is a build counterfactual, not a runtime
output divergence.
