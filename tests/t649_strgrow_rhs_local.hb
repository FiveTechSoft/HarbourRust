function main()
   local s := "" + "x"
   local r := "" + "y"
   for i := 1 to 1000
      s = s + "z"
   next
   r = r + s
   ? len( r )
   ? hb_memcheck()
   return
