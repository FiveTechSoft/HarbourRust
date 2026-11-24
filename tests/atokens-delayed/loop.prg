PROCEDURE Main()
 LOCAL x:=NIL,a:=NIL,i:=0,n:=0
 FOR i:=1 TO 137
  FOR EACH x IN hb_ATokens("a;b"+hb_eol()+hb_eol()+"x;;y",hb_eol())
   IF !Empty(x)
    a:=hb_ATokens(x,";")
    n+=Len(a)
    ? a[1],a[Len(a)]
   ENDIF
  NEXT
 NEXT
 ? n,ValType(x)
RETURN
