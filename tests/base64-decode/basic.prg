PROCEDURE Main()
 LOCAL s:="Zm9vYmFy",d:=NIL,i:=0,k:=""
 FOR i:=1 TO 101
  ? hb_base64Decode(""),hb_base64Decode("Zg=="),hb_base64Decode("Zm8="),hb_base64Decode("Zm9v")
  ? hb_base64Decode(s),s,hb_StrToHex(hb_base64Decode("/w=="))
  d:="AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8="
  k:=hb_base64Decode(d)
  ? hb_StrToHex(k),hb_base64Decode(Upper("zm9v"))
 NEXT
RETURN
