PROCEDURE Main()
 LOCAL n:=NIL,m:=0
 ? ValType(n)
 FOR n:=StartIt() TO BoundIt(m)
  ? "body",n
  m++
 NEXT
 ? "post",n
RETURN
FUNCTION StartIt()
 ? "start"
RETURN 1
FUNCTION BoundIt(m)
 ? "bound",m
RETURN 3-m
