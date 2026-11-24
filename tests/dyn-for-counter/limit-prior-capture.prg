PROCEDURE Main()
 LOCAL n:=NIL,b:={||n}
 ? ValType(n)
 FOR n:=1 TO 3
  ? Eval(b)
 NEXT
RETURN
