PROCEDURE Main()
 ? f(), f(11), f(11,22,33)
 RETURN
FUNCTION f(a,...)
 ? ValType(a), a, PCount(), hb_PValue(2), hb_PValue(3), hb_PValue(4)
 RETURN 7
