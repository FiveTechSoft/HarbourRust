#include "hbclass.ch"
CLASS K
   DATA n INIT 1
   METHOD M(x)
ENDCLASS
METHOD M(x) CLASS K
RETURN x
FUNCTION Keep(x)
 IF x == NIL
  x := NIL
 ENDIF
RETURN x
FUNCTION Round1(nn)
 LOCAL i, o, d, p, e, hits, sum, a, b
 hits := 0
 sum := 0
 FOR i := 1 TO nn
  o := K():New()
  o:n := 7
  p := K():New()
  p:n := 5
  d := Keep(p)
  TRY
   o:M(d)
  CATCH e
   hits := hits + 1
  END
  a := K():New()
  b := K():New()
  a:n := 11
  b:n := 13
  sum := sum + o:n + p:n + a:n + b:n
  o := NIL
  p := NIL
  d := NIL
  e := NIL
  a := NIL
  b := NIL
 NEXT
 ? "hits", hits
RETURN sum
FUNCTION Main()
 LOCAL baseline, s
 s := Round1(1)
 baseline := hb_memcheck()
 s := Round1(1)
 ? "sum", s
 ? "pending", hb_memcheck() - baseline
RETURN NIL
