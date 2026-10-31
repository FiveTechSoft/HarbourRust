// pos: observable variant of the t711 admission - a logical stored
// into a Dyn slot (tag 3) reads back as a logical.
procedure main()
   p( .t. )
   return
function p( x )
   ? x
   x := .f.
   ? x
   return
