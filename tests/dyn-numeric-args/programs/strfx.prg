// Str with an invalid Dyn first argument: width/dec evaluate before the kind check (entered counts), and the error is catchable under try. A throwing width inside the try is NOT gated here: it trips a pre-existing frame mismatch on the base compiler (separate finding).
STATIC entered := 0
function Ok( x )
return x
function Tick()
 entered := entered + 1
return 1
function Main()
 local a, n, s, r
 a := Ok( 1.5 )
 n := NIL
 s := Ok( "x" )
 try
  r := Str( n, Tick() )
  ? "not reached"
 catch
  ? "str-nil-tick", entered
 end
 try
  r := Str( Ok( s ), Tick() )
  ? "not reached"
 catch
  ? "str-own-tick", entered
 end
 try
  r := Str( n )
  ? "not reached"
 catch
  ? "str-nil", entered
 end
 ? "str-ok", Str( a, Tick() ), entered
return nil
