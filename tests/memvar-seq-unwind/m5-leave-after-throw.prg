function Ok( x )
return x
function Boom()
 Break( "expected" )
return 3
function Main()
 local a, r
 a := Ok( 7 )
 try
  r := Boom()
 catch
  ? "caught"
 end
 r := Ok( 2 )
 ? "x", Str( a )
 ? "end"
return nil
