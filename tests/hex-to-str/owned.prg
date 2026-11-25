PROCEDURE Main()
 LOCAL s:=Lower("41FF00"),t:="",i:=0
 FOR i:=1 TO 101
 t:=hb_HexToStr(s)
 ? hb_StrToHex(t),s,hb_StrToHex(hb_HexToStr(Lower("AABB"))),hb_HexToStr("41"+"42")
 NEXT
 ? hb_StrToHex(Probe("ff00")),s,hb_HexToStr(hb_StrToHex("a"+Chr(0)+"b"))
RETURN
FUNCTION Probe(s)
RETURN hb_HexToStr(s)
