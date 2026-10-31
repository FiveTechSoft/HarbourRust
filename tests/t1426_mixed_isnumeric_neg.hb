// hb_isnumeric is not in piece 1a; the builtin lands in a later slice
function main()
   local a := { 1, "x", NIL }
   ? hb_isnumeric(a[1])
   return nil
