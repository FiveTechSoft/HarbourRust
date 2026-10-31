function work()
   local a := {}
   a := {1,"x",NIL}
   local b := a
   ? b[2]
   return nil
function main()
   work()
   ? hb_memcheck()
   return nil
