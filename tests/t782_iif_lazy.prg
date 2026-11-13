procedure main()
   local x := 5
   ? iif( x == 5, "passed", "fail" )
   ? iif( x == 4, "passed", "fail" )
   ? iif( x > 0, 1.5, 2 )
   ? iif( .t., "good", sidefx() )
   ? iif( .f., sidefx(), "good2" )
return

function sidefx()
   ? "SIDEFX-CALLED"
return "bad"
