function Consume( s )
return s + "!"
function Main()
 local s := "a" + "b"
 ? Round( 1.5, 1, Consume( s ) )
 ? "after", s
return nil
