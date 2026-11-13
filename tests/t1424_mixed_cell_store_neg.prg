// the cell owns its payload; a Dyn local would free it again
function main()
   local a := { 1, "x", NIL }
   local x := a[2]
   return nil
