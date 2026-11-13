// neg: a type error in a forward call is still detected - emitted by
// the converged round, never masked by placeholder rounds.
procedure main()
   ? fwd( "x" )
   return
function fwd( n )
   return n + 1
