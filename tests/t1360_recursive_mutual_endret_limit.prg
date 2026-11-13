// Mutual recursion with the RETURN only at the END of each body stays
// the named inference limit: no return is reached before the mutual
// call, so neither return type materializes and the fixpoint
// converges on the named error (fib piece; direct self-recursion and
// early-return mutual forms are the covered shapes).
function isodd( n )
   local r
   if n == 0
      r := 0
   else
      r := iseven( n - 1 )
   endif
return r
function iseven( n )
   local r
   if n == 0
      r := 1
   else
      r := isodd( n - 1 )
   endif
return r
function main()
   ? isodd( 3 )
return nil
