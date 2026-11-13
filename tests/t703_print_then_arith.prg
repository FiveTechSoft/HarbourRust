// pos (63r): printing plus arithmetic - the arithmetic pin wins over the
// print evidence order-independently (oracle hk260: prints 5, returns 6).
procedure main()
   ? p( 5 )
   return
function p( x )
   ? x
   return x + 1
