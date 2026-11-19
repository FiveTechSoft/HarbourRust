function Toss()
 private value := 30
 Break( "expected" )
return nil
function Middle()
 local e
 private value := 20
 try
  Toss()
 catch e
  ? "middle", value
  Break( e )
 end
return nil
function Main()
 local e
 private value := 10
 try
  Middle()
 catch e
  ? "main", value
 end
return nil
