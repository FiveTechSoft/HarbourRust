procedure main()
   local x := 5
   local s := "a" + "b"
   ? iif( x == 5, "con" + "cat", "other" )
   ? hb_memcheck()
   ? iif( x == 4, "con" + "cat", "own" + "ed" )
   ? hb_memcheck()
   ? iif( .t., s, "x" )
   ? hb_memcheck()
return
