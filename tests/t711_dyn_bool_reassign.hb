// neg (63s): assigning a logical INTO a Dyn slot is not in this increment -
// Dyn-slot logical stores land with the tag-L local increment (registered
// limit; the admission boundary is call arguments only).
procedure main()
   p( .t. )
   return
function p( x )
   ? x
   x := .f.
   return
