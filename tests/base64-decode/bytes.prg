PROCEDURE Main()
 LOCAL s:="",i:=0,t:=""
 FOR i:=0 TO 255
  s:=s+Chr(i)
 NEXT
 t:=hb_base64Decode(hb_base64Encode(s))
 ? t==s,Len(t),hb_StrToHex(t)
RETURN
