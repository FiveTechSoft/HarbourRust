// the caught value is what was thrown, round after round, with the catch variable reused
function Main()
 local i, e, d, a, b
 a := 1.5
 b := 2
 for i := 1 to 3
  try
   Break( "lit" + Str( i, 2 ) )
  catch e
   ? "str", e
  end
  try
   d := a * b
   Break( d )
  catch e
   ? "flt", e
  end
  try
   Break( i * 10 )
  catch e
   ? "int", e
  end
  try
   Break( NIL )
  catch e
   ? "nil", e
  end
  try
   d := { 1, "x" }
   Break( d )
  catch e
  end
 next
 e := "mine"
 try
  Break( "t" )
 catch e
  ? "reassigned", e
 end
return nil
