PROCEDURE Main()
 LOCAL s:="",t:="",i:=0
 FOR i:=0 TO 255
 s+=Chr(i)
 NEXT
 t:=hb_HexToStr(s)
 ? Len(t),hb_StrToHex(t)
 ? hb_StrToHex(hb_HexToStr(hb_StrToHex(s)))==hb_StrToHex(s)
 ? Len(hb_HexToStr(Replicate("0x41-",1025)))
RETURN
