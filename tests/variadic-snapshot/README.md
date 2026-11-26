# Variadic scalar snapshots B

Own MIT black-box increment, based only on own programs and compiled oracle.
`LOCAL a := hb_AParams()` at the start of a variadic function snapshots all
actual scalar argument values into an owned array. Empty calls yield empty
arrays. Later scalar parameter writes do not change the earlier snapshot;
array writes do not change the parameter. Returning the snapshot is supported
through the existing array ownership path.

Lowering uses existing empty-array, PCount, hb_PValue and AAdd semantics.
No runtime or global RC change. User-defined hb_AParams takes precedence.
Overridden PCount/hb_PValue block lowering. Only top-level leading LOCAL
initializers are rewritten. Assignment, arguments, late/nested declarations,
other expression forms and nonvariadic functions keep named rejections.
All variadic A profile/type/lifetime guards still apply. No forwarding or
ellipsis splicing. Original1041 closures must be measured, not inferred.
