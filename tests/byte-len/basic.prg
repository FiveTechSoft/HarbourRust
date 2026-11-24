PROCEDURE Main()
 LOCAL s:="",i:=0
 ? hb_BLen(""),hb_BLen("abc"),hb_BLen("á路径"),hb_BLen("a"+Chr(0)+"b")
 FOR i:=0 TO 255
 s+=Chr(i)
 ? i,hb_BLen(s)
 NEXT
 ? hb_BLen(Replicate("á",4097)),hb_BLen(hb_HexToStr("00FF00"))
RETURN
