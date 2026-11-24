PROCEDURE Main()
 First()
 OtherWork()
 First()
RETURN
FUNCTION First()
 LOCAL n:=NIL
 ? ValType(n)
 FOR n:=1 TO 2
  ? n
 NEXT
RETURN NIL
FUNCTION OtherWork()
 LOCAL x:=7
 ? Eval({||7}),x
RETURN NIL
