FUNCTION Unused(p)
RETURN p
FUNCTION Forward(p)
 LOCAL x := p
RETURN x
FUNCTION Exercise()
 LOCAL i, u := NIL
 FOR i := 1 TO 100
  u := Forward("texto")
  u := Forward(i)
  u := Forward(Forward("anidado"))
  u := Forward(.T.)
 NEXT
RETURN NIL
FUNCTION Main()
 LOCAL i, baseline
 Exercise()
 baseline := hb_memcheck()
 FOR i := 1 TO 20
  Exercise()
 NEXT
 ? "pending", hb_memcheck() - baseline
RETURN NIL
