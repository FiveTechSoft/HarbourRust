function work()
   local a := {}
   local i
   for i := 1 to 2
      a := {1,"x",NIL}
   next
   ? a[2]
   return nil
function main()
   work()
   ? hb_memcheck()
   return nil
