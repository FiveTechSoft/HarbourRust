PROCEDURE Main()
 LOCAL a:={"Zg=="},v:=NIL,s:=""
 FOR EACH v IN a
  a[1]:="Zm8="
  s:=hb_base64Decode(v)
 NEXT
RETURN
