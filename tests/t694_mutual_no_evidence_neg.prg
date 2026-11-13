// neg: mutual recursion with no type evidence and no value return is
// rejected by the CONVERGED fixpoint (the ret=None cycle is the stable
// state, not a dropped placeholder error).
procedure main()
   ? ma( 1 )
   return
function ma( n )
   return mb( n )
function mb( n )
   return ma( n )
