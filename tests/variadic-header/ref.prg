PROCEDURE Main()
 LOCAL a := 3
 f(@a,7)
 ? a
 RETURN
FUNCTION f(a,...)
 a:=9
 ? PCount(), hb_PValue(2)
 RETURN NIL
