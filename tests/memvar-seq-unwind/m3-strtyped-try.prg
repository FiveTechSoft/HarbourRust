function Boom()
 Break( "expected" )
return 3
function Main()
 local a := 7, r
 ? "x", Str( a )
 try
  r := Boom()
 catch
  ? "caught"
 end
 ? "end"
return nil
