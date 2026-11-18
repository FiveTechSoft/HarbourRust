STATIC entered := 0
function Boom()
 entered := entered + 1
 Break( "expected" )
return 3
function Main()
 local a, b, s
 a := 1.5
 b := 2
 b := a * b
 s := "x"
 try
  s := a * 2
  ? s, Boom()
 catch
  ? "caught", entered
 end
return nil
