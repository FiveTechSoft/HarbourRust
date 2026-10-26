// neg (63r): an array argument to a print-only (Dyn) parameter is a named
// rejection - the tagged union has no array cell (oracle hk258: Harbour
// prints an empty line; replicating that needs Dyn storage this PoC does
// not have).
procedure main()
   local a := {}
   aadd( a, 1 )
   showit( a )
   return
function showit( x )
   ? x
   return
