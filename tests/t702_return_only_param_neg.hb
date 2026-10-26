// neg (63r): a parameter the body only RETURNS carries no type evidence -
// printing pins Dyn (hk257/hk259), but returning or copying is still not
// enough (63n/63o convergence unchanged).
procedure main()
   ? q( "ab" )
   return
function q( x )
   return x
