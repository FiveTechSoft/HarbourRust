// piece 1b landed hb_isnumeric for measured shapes; an unmeasured depth
// stays a named rejection (never inferred across depths).
function main()
   local a := { 1, "x", NIL }
   ? hb_isnumeric(a[1][1])
   return nil
