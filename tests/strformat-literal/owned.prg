PROCEDURE Main()
 LOCAL s:=Lower("OWNED"),x:=NIL,i:=0,result:=""
 FOR i:=1 TO 71
  result:=hb_StrFormat("(%s:%s)",s,s)
  ? result,s,Len(hb_StrFormat("%s",s))
  BEGIN SEQUENCE
   ? hb_StrFormat("%s|%s",s,x)
  RECOVER
   ? "unexpected"
  END SEQUENCE
 NEXT
RETURN
