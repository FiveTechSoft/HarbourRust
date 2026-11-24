PROCEDURE Main()
 LOCAL n:=NIL,m:=NIL
 ? ValType(n)
FOR n:=1 TO 3
 Eval({||n})
NEXT
RETURN
FUNCTION F(x)
 x:=2
RETURN NIL
