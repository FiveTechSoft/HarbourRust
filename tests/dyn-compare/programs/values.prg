// Comparisons with a Dyn that holds a float (conditions, logical values), and arithmetic in the operands. Independent fixture.
STATIC entered := 0
function Two()
return 2
function Fl()
return 2.5
function FlBoom()
 entered := entered + 1
 Break( "expected" )
return 2.5
function Main()
 local a, b, c, n, s, i, r
 a := 1.5
 b := 7
 c := 0.25
 n := NIL
 s := "x"
 ? "gt-int", a > 1
 ? "lt-int", a < 2
 ? "ge-lit", a >= 1.5
 ? "le-lit", a <= 1.4
 ? "lt-flit", a < 2.5
 ? "gt-flit-left", 2.5 > a
 ? "eq-lit", a = 1.5
 ? "exact-eq-lit", a == 1.5
 ? "exact-neq-lit", a == 1.25
 ? "ne-lit", a != 1.5
 ? "ne-int", a <> 2
 ? "exact-int", a == 2
 ? "lt-dyn", a < c
 ? "gt-dyn", a > c
 ? "ge-self", a >= a
 ? "eq-self", a == a
 ? "eq-dyn-int", a = b
 ? "int-dyn-gt", b > a
 ? "int-eq", b == 7
 ? "int-gt", b > 3
 ? "sum-gt", a + 1 > 2
 ? "diff-lt", a - b < 0
 ? "prod-ge", a * 2 >= 3
 ? "flit-lt-sum", 2.5 < a + 1
 ? "sum-exact", a + 1 == 2.5
 ? "prod-gt-flit", a * 2 > 2.5
 ? "neg-lt", -a < 0
 ? "sum-gt-diff", a + c > a - c
 ? "call-gt", Fl() > a
 ? "lt-call", a < Fl()
 if a + 1 > 2
  ? "if-sum-gt"
 endif
 if a > 1 .and. c < 1
  ? "if-and"
 endif
 if a < 1 .or. a * 2 > 2.5
  ? "if-or"
 endif
 if .not. ( a + 1 < 2 )
  ? "if-not"
 endif
 if a + 1 == 2.5
  ? "if-eq"
 else
  ? "if-else"
 endif
 i := 0
 do while a + i < 4
  i := i + 1
 enddo
 ? "while", i
 i := 0
 do while a * i < 5.5
  i := i + 1
 enddo
 ? "while-prod", i
 r := a + 1 > 2
 ? "assign", r, Valtype( r )
 ? "print", a + 1 > 2, a * 2 < 1
 try
  r := a > FlBoom()
  ? "not reached"
 catch
  ? "right-throw", entered
 end
 try
  r := a + 1 > FlBoom()
  ? "not reached"
 catch
  ? "right-throw-sum", entered
 end
 try
  r := FlBoom() < a + 1
  ? "not reached"
 catch
  ? "left-throw", entered
 end
 try
  r := n < 1
  ? "not reached"
 catch
  ? "nil-lt-error"
 end
 try
  r := a < n
  ? "not reached"
 catch
  ? "float-nil-lt-error"
 end
 try
  r := s < 2
  ? "not reached"
 catch
  ? "string-int-lt-error"
 end
 ? "nil-eq-float", n = a
 ? "float-eq-nil", a = n
 ? "nil-ne-float", n != a
 ? "a", a
return nil
