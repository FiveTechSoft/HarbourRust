// pos (63r): the same print-only parameter called with a string, an
// integer and NIL (oracle hk257 minus the logical call - tag-L Dyn cells
// are a separate registered increment, t708 locks the rejection).
procedure main()
   showit( "text" )
   showit( 42 )
   showit( nil )
   return
function showit( x )
   ? x
   return
