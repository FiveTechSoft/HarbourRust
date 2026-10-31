function work()
   local a := {1, "xyz", NIL}
   a := {2, "another", .T., NIL}
   ? a[1]
   ? a[2]
   return nil
function main()
   work()
   ? hb_memcheck()
   return nil
