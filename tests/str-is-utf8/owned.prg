PROCEDURE Main()
 LOCAL s:=Lower("AÁZ"),i:=0
 FOR i:=1 TO 101
 ? hb_StrIsUTF8(s),s,hb_StrIsUTF8(Lower("ÁZ")),hb_StrIsUTF8("a"+"á")
 NEXT
 ? hb_StrIsUTF8(Chr(192)+Chr(128)),hb_StrIsUTF8(Chr(237)+Chr(160)+Chr(128)),hb_StrIsUTF8(Chr(244)+Chr(144)+Chr(128)+Chr(128))
 ? hb_StrIsUTF8("á"+Chr(0)+Chr(255)),hb_StrIsUTF8(Chr(0)+"á"),hb_StrIsUTF8("á"+Chr(0))
 ? Probe("á"),Probe("ascii")
RETURN
FUNCTION Probe(s)
RETURN hb_StrIsUTF8(s)
