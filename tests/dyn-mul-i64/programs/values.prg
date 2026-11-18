// Dyn * integer and integer * Dyn, with a float or an integer in the Dyn operand. Independent fixture.
STATIC entered := 0
function Two()
return 2
function Boom()
 entered := entered + 1
 Break( "expected" )
return 3
function Main()
 local a, b, c, d, r, s, i
 a := 1.5
 c := 0.25
 b := 7
 s := "x"
 ? "lit", a * 2
 ? "lit", 2 * a
 ? "lit", c * 4
 ? "lit", 4 * c
 ? "call", a * Two()
 ? "call", Two() * a
 ? "call", a * Two() * Two()
 r := a * 2
 ? "assign", r, Valtype( r )
 r := a * ( d := 3 )
 ? "setexpr", r, d
 r := ( d := 4 ) * a
 ? "setexpr-left", r, d
 r := a * Two() * c
 ? "chain", r
 ? "intdyn", b * 2
 ? "intdyn", 2 * b
 ? "intdyn", b * Two()
 ? "intdyn", Two() * b
 ? "pure-after", a * 2, 7, b, "s"
 ? "throw-first", 1
 r := b * 2
 ? "intdyn-assign", r, Valtype( r )
 for i := 1 to 3
  r := a * i
  ? "loop", i, r
 next
 try
  r := a * Boom()
  ? "not reached"
 catch
  ? "right-throw", entered, a
 end
 try
  r := Boom() * a
  ? "not reached"
 catch
  ? "left-throw", entered, a
 end
 try
  r := s * 2
  ? "not reached"
 catch
  ? "string-error"
 end
 try
  r := 2 * s
  ? "not reached"
 catch
  ? "string-error-left"
 end
return nil
