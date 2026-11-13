function work()
   local a := {}
   a := {1,"x",NIL}
   ? a[2]
   return nil
function main()
   work()
   work()
   ? hb_memcheck()
   return nil
