PROCEDURE Main()
 LOCAL i:=0
 PRIVATE x:="private"
 FOR i:=1 TO 71
  ? hb_StrFormat("%s/%s",x,x)
  x:=17
  ? hb_StrFormat("%s",x)
  x:=1.25
  ? hb_StrFormat("%s",x)
  x:="private"
 NEXT
RETURN
