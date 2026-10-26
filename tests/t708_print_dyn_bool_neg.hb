// neg (63r): a logical argument to a print-only (Dyn) parameter is not in
// this increment - tag-L Dyn cells land separately (registered limit;
// oracle hk257 shows Harbour accepts it).
procedure main()
   showit( .t. )
   return
function showit( x )
   ? x
   return
