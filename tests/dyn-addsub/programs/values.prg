// Dyn + integer, Dyn - integer, Dyn +/- Dyn and unary minus, with a float or an integer in the Dyn operand. Independent fixture.
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
 ? "add", a + 1
 ? "add-left", 1 + a
 ? "sub", a - 1
 ? "sub-left", 1 - a
 ? "dyn-add", a + c
 ? "dyn-sub", a - c
 ? "dyn-add-self", a + a
 ? "dyn-sub-self", a - a
 ? "call", a + Two()
 ? "call", Two() + a
 ? "call", a - Two()
 ? "call", Two() - a
 ? "chain", a + c + 1
 ? "chain", a - c - 1
 ? "chain", a + 1 - c
 ? "mixed", a * 2 + c
 ? "mixed", a + c * 4
 ? "neg", -a
 ? "neg-int", -b
 ? "neg-neg", - -a
 r := a + 1
 ? "assign", r, Valtype( r )
 r := a - c
 ? "assign-dyn", r, Valtype( r )
 r := a + ( d := 3 )
 ? "setexpr", r, d
 r := ( d := 4 ) - a
 ? "setexpr-left", r, d
 r := -a
 ? "assign-neg", r
 ? "int", b + 1
 ? "int", b - 1
 ? "int", 1 - b
 ? "int", b + b
 ? "int", b - b
 ? "int-neg", -b
 ? "int-assign", b + Two()
 ? "pure-after", a + 1, 7, b, "s"
 ? "dec", c - 1
 ? "big", a + 100000000000
 ? "big", -100000000000 - a
 for i := 1 to 3
  r := a + i
  ? "loop-add", i, r
  r := a - i
  ? "loop-sub", i, r
 next
 try
  r := a + Boom()
  ? "not reached"
 catch
  ? "right-throw-add", entered, a
 end
 try
  r := Boom() - a
  ? "not reached"
 catch
  ? "left-throw-sub", entered, a
 end
 try
  r := s + 1
  ? "not reached"
 catch
  ? "string-int-add-error"
 end
 try
  r := a + s
  ? "not reached"
 catch
  ? "float-string-add-error"
 end
 try
  r := a - s
  ? "not reached"
 catch
  ? "float-string-sub-error"
 end
 try
  r := -s
  ? "not reached"
 catch
  ? "neg-string-error"
 end
 ? "a", a
return nil
