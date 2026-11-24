PROCEDURE Main()
 LOCAL x:="a;b;;c",i:=0,n:=0,j:=0
 FOR j:=1 TO 127
  FOR i:=1 TO 7
   LOCAL a:=NIL
   a:=hb_ATokens(x,";")
   n+=Len(a)
   IF i==2
    LOOP
   ENDIF
   IF i==5
    EXIT
   ENDIF
  NEXT
 NEXT
 ? n
RETURN
