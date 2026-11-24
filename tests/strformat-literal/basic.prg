PROCEDURE Main()
 LOCAL s:="owned",x:=NIL,i:=0
 FOR i:=1 TO 71
  ? hb_StrFormat("%s|%s|%s|%s|%%", "abc", NIL, 17, .T.)
  ? hb_StrFormat("%s",-1)
  ? hb_StrFormat("plain"),hb_StrFormat(""),hb_StrFormat("%%%s%%","q")
  ? hb_StrFormat("%s/%s",s,s),s
  x:="dynamic"
  ? hb_StrFormat("%s/%s",x,x),x
  x:=17
  ? hb_StrFormat("%s",x)
  x:=1.25
  ? hb_StrFormat("%s",x)
  x:=.F.
  ? hb_StrFormat("%s",x)
  x:=NIL
  ? hb_StrFormat("%s",x)
 NEXT
RETURN
