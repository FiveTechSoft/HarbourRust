// Bounds before the right side (verifier-observed Harbour order,
// results-6de7d717 bounds_rhs_order): with a VARIABLE out-of-range
// index, a[i] op= e raises the bound error WITHOUT running e - bump
// must never print RHS-EFFECT (a literal 0 is a compile-time
// rejection, so the runtime order needs a variable index).
function bump()
   ?? "RHS-EFFECT "
return 5
function main()
   local a := { 1, 2 }
   local i := 0
   ? a[ i ] += bump()
return nil
