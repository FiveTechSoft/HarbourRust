procedure main()
   local x := 5
   p( x == 5 )
   p( x == 4 )
   ? ( x == 5 ) .and. ( x > 0 )
return

function p( b )
   ? b
return nil
