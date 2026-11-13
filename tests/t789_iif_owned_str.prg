procedure main()
   local x := 5
   ? iif( x == 5, "con" + "cat", "other" )
   ? iif( x == 4, "con" + "cat", "own" + "ed" )
   ? iif( .t., 7, 2.5 )
   ? iif( .f., 7, 2.5 )
return
