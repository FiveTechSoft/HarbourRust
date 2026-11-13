// cell overwrite (freeing the old payload) lands in the next piece
function main()
   local a := { 1, "x", NIL }
   a[1] := 5
   return nil
