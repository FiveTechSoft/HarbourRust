PROCEDURE Main()
 LOCAL a:=NIL,x:="a;;b",i:=0,n:=0
 FOR i:=1 TO 149
  IF i%2==0
   a:=hb_ATokens(x,";")
  ELSE
   a:=hb_ATokens(x,",")
  ENDIF
  n+=Len(a)
 NEXT
 ? n
RETURN
