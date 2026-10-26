// neg: adjacent `--` in an expression is Harbour pre-decrement, NOT double
// negation - before this increment it parsed as -(-x) = x (silent
// miscompile vs Harbour, hk246). Now a named rejection.
function main()
   local x := 1
   local y := --x
   ? y
   return
