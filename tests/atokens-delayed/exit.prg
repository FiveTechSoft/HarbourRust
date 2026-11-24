PROCEDURE Main()
 LOCAL a:=NIL,x:="a;b",i:=0
 FOR i:=1 TO 111
  IF i==1
   LOOP
  ENDIF
  a:=hb_ATokens(x,";")
  ? Len(a)
  IF i==19
   EXIT
  ENDIF
 NEXT
RETURN
