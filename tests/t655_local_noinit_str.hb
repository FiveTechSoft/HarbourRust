function main()
   local s
   s := "abc"
   ? s
   ? valtype( s )
   s := NIL
   ? hb_memcheck()
   return
