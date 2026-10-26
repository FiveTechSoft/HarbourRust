function f()
   return "XY"
function main()
   local s := "" + "a"
   for i := 1 to 50
      s = s + f()
   next
   ? len( s )
   ? hb_memcheck()
   return
