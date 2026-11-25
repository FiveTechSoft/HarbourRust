PROCEDURE Main()
 LOCAL s:=Lower("ABC"),i:=0,n:=0
 FOR i:=1 TO 101
 n:=hb_BLen(s)
 ? n,s,hb_BLen(Lower("XYZ")),hb_BLen("A"+"B"),hb_BLen(hb_ASCIILower("AB"))
 NEXT
 ? Probe("abc"),Probe("")
RETURN
FUNCTION Probe(s)
RETURN hb_BLen(s)
