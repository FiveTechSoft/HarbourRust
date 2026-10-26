// pos (63t): a Dyn parameter as the condition - logical cells decide the
// branch (oracle hk266: .T. -> yes, .F. -> no, exit 0).
procedure main()
   p( .t. )
   p( .f. )
   return
function p( x )
   ? x
   if x
      ? "yes"
   else
      ? "no"
   endif
   return
