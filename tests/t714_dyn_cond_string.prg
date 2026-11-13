// posx 1 (63t): a string Dyn cell in condition position is Harbour's
// type error (oracle hk268) - clean named exit 1. Before 63t the string
// pointer leaked through as truthy (silent divergence).
procedure main()
   p( "abc" )
   return
function p( x )
   ? x
   if x
      ? "yes"
   endif
   return
