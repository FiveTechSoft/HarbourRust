// pos (was neg 63s; SOURCE UNCHANGED, role converted with oracle
// capture): a logical store into a Dyn slot lands tag 3 - the parexpr
// piece admits it (the original assigns booleans into NIL-holding
// locals). Readback pinned separately in t1382.
procedure main()
   p( .t. )
   return
function p( x )
   ? x
   x := .f.
   return
