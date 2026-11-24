FUNCTION Kind(x)
RETURN ValType(x)
FUNCTION PutKind(a)
 LOCAL c:=Kind(a[1])
 a[1]:=c
RETURN NIL
FUNCTION Main()
 LOCAL a:={7,8},i
 FOR i:=1 TO 157
  PutKind(a)
 NEXT
 ? a[1],a[2]
RETURN NIL
