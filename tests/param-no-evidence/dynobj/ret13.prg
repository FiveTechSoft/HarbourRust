#include "hbclass.ch"
CLASS K
   DATA n INIT 1
   DATA ref INIT NIL
ENDCLASS
FUNCTION Ident(x)
RETURN x
FUNCTION Consume(x)
RETURN NIL
FUNCTION Two(x, y)
RETURN NIL
FUNCTION Keep(x)
 IF x == NIL
  x := NIL
 ENDIF
RETURN x
FUNCTION Round1(nn, lim)
 LOCAL i, o, d, e, p, q, hits, sum, s
 hits := 0
 sum := 0
 FOR i := 1 TO nn
  o := K():New()
  o:n := 7
  d := Keep(o)
  TRY
   Consume(Keep(o))
  CATCH e
   hits := hits + 1
  END
  p := K():New()
  q := K():New()
  p:n := 11
  q:n := 13
  sum := sum + o:n + p:n + q:n
  o := NIL
  d := NIL
  e := NIL
  p := NIL
  q := NIL
  s := NIL
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
