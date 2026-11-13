function main()
   local s := "" + "abc"
   s = s + s
   ? s
   s = s + s
   ? len( s )
   ? hb_memcheck()
   return
