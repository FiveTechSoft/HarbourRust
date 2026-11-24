FUNCTION Main()
 ? Set(_SET_EPOCH),Set(5,1950),Set(5),Set(5,NIL),Set(5)
 ? DToS(CToD("01/01/49")),DToS(CToD("01/01/50"))
 ? Set(5,2001),Set(5),Set(5,0),Set(5),Set(5,9999),Set(5)
 SET EPOCH TO 1950
 ? Set(5),DToS(CToD("12/31/49"))
RETURN NIL
