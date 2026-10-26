// pos (63r, flipped from neg): a forward call whose argument reaches the
// callee's print-only parameter - the parameter pins to the tagged union
// (oracles hk257/hk259: Harbour routes any scalar through a print-only
// parameter). Byte output and exit match Harbour for `? s; return s`.
procedure main()
   ? sff( "ab" )
   return
function sff( s )
   ? s
   return s
