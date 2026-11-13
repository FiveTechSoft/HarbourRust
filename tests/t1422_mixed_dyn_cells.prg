// ains piece 1a: a mixed scalar literal types as a Dyn-cell dynamic
// array; cells read in place (printing, ValType) and the array owns
// its payloads through scope exit (memcheck 0 across two calls).
function work()
   local a := { 1, "x", NIL, .T. }
   ? ValType(a[1])
   ? ValType(a[2])
   ? ValType(a[3])
   ? ValType(a[4])
   ? a[1]
   ? a[2]
   ? a[3]
   ? a[4]
   return nil
function main()
   work()
   work()
   ? hb_memcheck()
   return nil
