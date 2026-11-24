PROCEDURE Main()
 LOCAL a:={"x"=>"Zg=="},v:=NIL,s:=""
 FOR EACH v IN a
  hb_HClear(a)
  s:=hb_base64Decode(v)
 NEXT
RETURN
