#include "hbclass.ch"
CLASS K
   DATA n INIT 1
ENDCLASS
FUNCTION Consume(x)
RETURN NIL
FUNCTION Ident(x)
RETURN x
FUNCTION Two(x, y)
RETURN NIL
FUNCTION Round1(nn)
 LOCAL i, o, d, e, p, q, hits, sum, s, f
 hits := 0
 sum := 0
 FOR i := 1 TO nn
  o := K():New()
  o:n := 7
  s := "str" + LTrim(Str(i))
  f := 1.5
  TRY
   Consume(5)
   Consume("lit")
   Consume(NIL)
   Consume(.T.)
   Consume(s)
   Consume(f)
   Two(s, f)
   e := Ident(s)
   e := Ident(f)
  CATCH e
   hits := hits + 1
  END
  p := K():New()
  p:n := 11
  sum := sum + o:n + p:n
  o := NIL
  e := NIL
  p := NIL
  s := NIL
  f := NIL
 NEXT
 ? "hits", hits
RETURN sum
FUNCTION Main()
 LOCAL baseline, s
 s := Round1(@N@)
 baseline := hb_memcheck()
 s := Round1(@N@)
 ? "sum", s
 ? "pending", hb_memcheck() - baseline
RETURN NIL
