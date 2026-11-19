// Max/Min with a Dyn operand and a throwing other argument. Kept apart from values.prg: a Str() of a Dyn value earlier in the same program makes a later try end with a frame mismatch on the base compiler (separate finding).
function Ok( x )
return x
function Boom()
 Break( "expected" )
return 3
function Main()
 local a, b, r
 a := Ok( 1.5 )
 b := Ok( 7 )
 try
  r := Max( a + 1, Boom() )
  ? "not reached"
 catch
  ? "max-throw-right"
 end
 try
  r := Min( Boom(), a + 1 )
  ? "not reached"
 catch
  ? "min-throw-left"
 end
 ? "a", a, "b", b
return nil
