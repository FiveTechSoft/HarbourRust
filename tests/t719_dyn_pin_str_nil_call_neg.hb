// neg (63u): comparing a parameter against a string literal pins it to a
// string; passing NIL is rejected by name at the call site after
// convergence (hk272 shape) - the diagnostic names the real mismatch.
procedure main()
   ? p( "ab" )
   ? p( nil )
   return
function p( x )
   return x == "ab"
