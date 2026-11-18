// Evaluation order and catchability with effects (STATIC entered counts argument evaluations). The oracle evaluates every argument before validating the first one's type.
STATIC entered := 0
function Ok( x )
return x
function Tick()
 entered := entered + 1
return 1
function Boom()
 entered := entered + 1
 Break( "expected" )
return 3
function Main()
 local a, n, s, r
 a := Ok( 1.5 )
 n := NIL
 s := Ok( "x" )
 try
  r := Mod( n, Tick() )
  ? "not reached"
 catch
  ? "mod-nil-tick", entered
 end
 try
  r := Round( n, Tick() )
  ? "not reached"
 catch
  ? "round-nil-tick", entered
 end
 try
  r := Mod( n, Boom() )
  ? "not reached"
 catch
  ? "mod-nil-boom", entered
 end
 try
  r := Round( n, Boom() )
  ? "not reached"
 catch
  ? "round-nil-boom", entered
 end
 try
  r := Mod( Ok( n ), Tick() )
  ? "not reached"
 catch
  ? "mod-callnil-tick", entered
 end
 try
  r := n % Tick()
  ? "not reached"
 catch
  ? "pct-nil-tick", entered
 end
 try
  r := n % Boom()
  ? "not reached"
 catch
  ? "pct-nil-boom", entered
 end
 ? "mod-ok", Mod( a, Tick() ), Mod( a + 1, Tick() ), entered
 ? "round-ok", Round( a, Tick() ), Round( a + 1.26, Tick() ), entered
 ? "pct-ok", a % Tick(), entered
 ? "entered", entered
return nil
