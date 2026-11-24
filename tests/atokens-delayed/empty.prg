PROCEDURE Main()
 LOCAL a:=NIL,x:=NIL,n:=0,i:=0,y:="z"
 FOR EACH x IN hb_ATokens("",hb_eol())
  a:=hb_ATokens(x,";")
  n+=Len(a)
 NEXT
 FOR i:=1 TO 0
  a:=hb_ATokens(y,";")
  n+=Len(a)
 NEXT
 ? n
RETURN
