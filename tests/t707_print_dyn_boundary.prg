// pos (63r): ownership boundary of a Dyn parameter - the call boundary
// clones the string payload (tag 4, callee owns and frees at its
// epilogue), the return hands the caller its own clone, and a printed
// call temporary frees its payload after printing. memcheck 0.
procedure main()
   local s := echo2( "abc" )
   ? s
   ? echo2( "de" )
   return
function echo2( x )
   ? x
   return x
