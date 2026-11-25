PROCEDURE Main()
 LOCAL a:={"one","two",""},v:=NIL,s:="",i:=0
 FOR i:=1 TO 51
  FOR EACH v IN a
   s:=hb_StrFormat("<%s:%s>",v,v)
   ? s,v
  NEXT
 NEXT
 ? s
RETURN
