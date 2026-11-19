function Boom()
 Break( "expected" )
return 3
function Main()
 local r
 try
  r := Boom()
 catch
  ? "caught"
 end
 ? "end"
return nil
