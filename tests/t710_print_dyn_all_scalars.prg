// pos (63s): one print-only parameter called with every scalar shape -
// string, integer, NIL and logical (oracles hk257 + hk264), exit 0.
procedure main()
   showit( "text" )
   showit( 42 )
   showit( nil )
   showit( .t. )
   return
function showit( x )
   ? x
   return
