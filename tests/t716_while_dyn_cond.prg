// pos (63u): a Dyn parameter as the DO WHILE condition - logical cells
// decide the loop (oracle hk270: .F. skips, .T. enters and EXIT leaves;
// byte-identical, exit 0).
procedure main()
   p( .f. )
   p( .t. )
   return
function p( x )
   ? x
   do while x
      ? "in"
      exit
   enddo
   ? "after"
   return
