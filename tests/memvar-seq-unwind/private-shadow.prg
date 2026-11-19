function Toss()
 private value := 20, temporary := "temporary"
 Break( "expected" )
return nil
function Main()
 local i, e
 private value := 10
 for i := 1 to 20
  try
   Toss()
  catch e
   ? "caught", value, __mvExist("temporary")
  end
 next
 ? "after", value
return nil
