PROCEDURE Main()
 LOCAL a:={"","Zg==","Zm8=","Zm9v","Zm9vYg=="},v:=NIL,s:="",i:=0
 FOR i:=1 TO 71
  FOR EACH v IN a
   s:=hb_base64Decode(v)
   ? hb_StrToHex(s)
  NEXT
 NEXT
 ? s,Fetch()
RETURN
FUNCTION Fetch()
RETURN hb_base64Decode("cmV0dXJu")
