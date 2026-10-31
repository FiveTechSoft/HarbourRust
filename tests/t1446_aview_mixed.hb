// ains 1b step (b): independent fixture, not Harbour source
// view boundary from DArrDyn: mixed scalar cells through the view
procedure main()
   local a := { 1, "x", NIL, .T. }
   show( a )
   ? len( a )
   return
procedure show( s )
   local n
   for n := 1 to len( s )
      ?? valtype( s[ n ] )
   next
   ?
   return
