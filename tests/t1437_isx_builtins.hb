// HB_ISNUMERIC/HB_ISARRAY (ains piece 1b): tag tests on measured shapes.
function main()
   local a := { 1, "x", NIL, .T. }
   local b := { { 1, 2 }, { 3, 4 } }
   ? hb_isnumeric(a[1])
   ? hb_isnumeric(a[2])
   ? hb_isnumeric(a[3])
   ? hb_isnumeric(a[4])
   ? hb_isarray(a[1])
   ? hb_isarray(b[1])
   ? hb_isnumeric(b[1])
   ? hb_isarray(b)
   ? hb_isnumeric(42)
   ? hb_isarray("s")
   ? hb_isnumeric(3.5)
   return nil
