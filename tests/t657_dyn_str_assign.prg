// Dyn slot holds an OWNED string (hk242): tag-4 casilla. Literal cloned at
// the boundary; reassign frees the old payload; string<->int transitions.
function main()
   local x
   x := "abc"
   ? x
   ? valtype( x )
   x := "abcdefgh"
   ? x
   x := 5
   ? x
   ? valtype( x )
   x := "z"
   ? x
   ? x == "z"
   ? x = "z"
   x := NIL
   ? hb_memcheck()
   return
