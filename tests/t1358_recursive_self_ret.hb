// Direct self-recursion return inference (fib piece): the recursive
// call sits before the RETURN whose expression feeds inference, so
// the function is seeded Dyn and the fixpoint refines from there.
// Own probe; fib.prg itself stays oracle-side only.
function fact( n )
   local r
   if n < 2
      r := 1
   else
      r := n * fact( n - 1 )
   endif
return r
function main()
   local i
   for i := 1 to 6
      ? fact( i )
   next
return nil
