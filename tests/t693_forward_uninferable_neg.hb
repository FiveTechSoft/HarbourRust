// neg: a forward call whose argument needs the callee's uninferable
// parameter must NOT be checked against the fixpoint placeholder (63n
// shipped that artifact: "must be an integer, got a string"); the
// converged rejection names the real root cause.
procedure main()
   ? sff( "ab" )
   return
function sff( s )
   ? s
   return s
