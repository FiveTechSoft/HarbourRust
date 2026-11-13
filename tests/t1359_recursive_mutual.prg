// Mutual recursion stays the named inference limit: neither function
// calls ITSELF, so no seed applies and the return types never
// materialize (fib piece; direct self-recursion is the covered form).
function isodd( n )
   if n == 0
      return .f.
   endif
return iseven( n - 1 )
function iseven( n )
   if n == 0
      return .t.
   endif
return isodd( n - 1 )
function main()
   ? isodd( 3 )
return nil
