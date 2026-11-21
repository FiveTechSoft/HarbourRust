# Len parameter string evidence

Own MIT inference change. Harbour is an external executable oracle only.

A direct Len(parameter) is weak collection evidence. Record its first line,
finish the existing body walk, then keep a string pin if present. Otherwise
apply the previous dynamic-array pin through pin_vars, which preserves root
parameter handling and existing conflict checks. Array/hash evidence still
merges through the existing setpin rules. Print-only evidence is unchanged.
No runtime, ABI, Bin/Cmp, Ret, trace, hb_At or workflow change.

28 own sources, 56 exact int/ext Linux oracle pairs. Both statement orders,
ASCII/empty/embedded-NUL, direct return/loop/branch/forward-before-move.
8 prior controls, 16 exact int/ext pairs, all accepted by baseline.
6 memory modes, 100 warmup + 10000 calls, exact totals and zero delta.
5 named build rejections keep string/array and numeric conflicts, wrong
boundary and use-after-move out. Four safe oracle controls execute.
4 own drivers include unchanged pinned originals xhbmisc/e2d/findith/nooccur,
8 exact int/ext pairs. This is library support, not new standalone acceptance.

Two Rust-valid inference mutants intentionally restore a named build
rejection. They are acceptance-killing mutants, not runtime divergences.
No rejected mutant program is executed. Four proxy simulations separately
check the positive gate fails closed on build failure, missing file, simulated
run-124 and wrong stdout. Proxies are not product mutants.

Broader parameter-polymorphism, owned Dyn string temporary admission and
new runtime coercion are outside this change. The use-after-move control
remains rejected even though Harbour copies at a user-function boundary.
