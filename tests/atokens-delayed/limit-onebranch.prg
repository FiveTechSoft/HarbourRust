PROCEDURE Main()
 LOCAL a:=NIL,x:="a;b",i:=0
 IF i==0
  a:=hb_ATokens(x,";")
 ENDIF
 ? Len(a)
RETURN
