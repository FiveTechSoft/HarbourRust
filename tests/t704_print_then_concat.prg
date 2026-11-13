// pos (63r): printing plus concatenation - the string pin wins over the
// print evidence order-independently (oracle hk261: prints ab, returns ab!).
procedure main()
   ? p( "ab" )
   return
function p( x )
   ? x
   return x + "!"
