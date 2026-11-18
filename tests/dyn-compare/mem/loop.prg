STATIC entered := 0
function Two()
return 2
function FlTwo()
return 2.5
function Boom()
 entered := entered + 1
 Break( "expected" )
return 3
function FlBoom()
 entered := entered + 1
 Break( "expected" )
return 2.5
function Own()
return "o" + "k"
function Round1( nn )
 local i, a, b, c, e, r, d, s, hits
 a := 1.5
 b := 7
 c := 0.25
 s := "x"
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
