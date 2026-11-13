// ains piece 1a: cells feed integer arithmetic (Dyn conversion) and
// several mixed arrays coexist, each freeing its own cells.
function work()
   local a := { 1, "x", NIL }
   local b := { 9, "yy", .F., NIL, 5 }
   ? ValType(a[2])
   ? ValType(b[3])
   ? b[1] + 1
   ? a[1] + b[5]
   return nil
function main()
   work()
   ? hb_memcheck()
   return nil
