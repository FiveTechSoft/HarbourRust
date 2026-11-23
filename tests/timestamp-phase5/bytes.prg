FUNCTION CheckValue(x)
RETURN Empty(x)
FUNCTION Main()
 LOCAL i,t:=hb_SToT("20261123")
 FOR i:=0 TO 32
  ? i,CheckValue(Chr(i))
 NEXT
RETURN NIL
