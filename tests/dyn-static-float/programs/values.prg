// A static float operand (literal or float-typed call) next to a Dyn, for + - *. Independent fixture.
STATIC entered := 0
function Fl()
return 2.5
function FlBoom()
 entered := entered + 1
 Break( "expected" )
return 2.5
function Main()
 local a, b, c, d, r, s, i
 a := 1.5
 c := 0.25
 b := 7
 s := "x"
 ? "lit-add", a + 2.5
 ? "lit-add-left", 2.5 + a
 ? "lit-sub", a - 0.25
 ? "lit-sub-left", 0.25 - a
 ? "lit-mul", a * 2.5
 ? "lit-mul-left", 2.5 * a
 ? "dec2", a + 1.25
 ? "dec3", c * 0.125
 ? "dec-max", c - 1.5
 ? "call-add", a + Fl()
 ? "call-sub", Fl() - a
 ? "call-mul", a * Fl()
 ? "int-dyn-lit", b + 2.5
 ? "int-dyn-lit", 2.5 - b
 ? "int-dyn-lit", b * 2.5
 ? "chain", a + c + 2.5
 ? "chain", a * 2.5 + c
 ? "chain", 2.5 + a - c
 ? "chain-neg", -a + 2.5
 ? "chain-int", a + 1 + 2.5
 ? "big", a + 123456789012.5
 ? "big", a * 99999999999.5
 r := a + 2.5
 ? "assign", r, Valtype( r )
 r := Fl() * c
 ? "assign-call", r
 r := a + ( d := 3 ) + 2.5
 ? "setexpr", r, d
 ? "pure-after", a + 2.5, 7, b, "s"
 for i := 1 to 3
  r := a + 2.5 * i
  ? "loop", i, r
 next
 try
  r := a + FlBoom()
  ? "not reached"
 catch
  ? "right-throw", entered, a
 end
 try
  r := FlBoom() - a
  ? "not reached"
 catch
  ? "left-throw", entered, a
 end
 try
  r := a * 2.5 + FlBoom()
  ? "not reached"
 catch
  ? "chain-throw", entered, a
 end
 try
  r := s + 2.5
  ? "not reached"
 catch
  ? "string-float-error"
 end
 try
  r := 2.5 - s
  ? "not reached"
 catch
  ? "float-string-error"
 end
 try
  r := s * 2.5
  ? "not reached"
 catch
  ? "string-mul-error"
 end
 ? "a", a
return nil
