STATIC entered := 0
function Boom()
 entered := entered + 1
 Break( "expected" )
return 3
function Tick()
 entered := entered + 1
return 1
function Id( x )
return x
function Round1( nn )
 local i, a, b, c, e, s, r, hits
 a := Id( 1.5 )
 b := Id( 7 )
 c := Id( -2.75 )
 s := Id( "x" )
 hits := 0
 r := NIL
 for i := 1 to nn
  r := NIL
  TRYBLOCK
 next
 ? "hits", hits
 ? "a", a
 ? "entered", entered
return r
function Main()
 local baseline, x
 x := Round1( @N@ )
 baseline := hb_memcheck()
 entered := 0
 x := Round1( @N@ )
 ? "pending", hb_memcheck() - baseline
return nil
