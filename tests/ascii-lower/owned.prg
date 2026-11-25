PROCEDURE Main()
 LOCAL s:=Upper("abc"),t:="",i:=0
 FOR i:=1 TO 101
 t:=hb_ASCIILower(s)
 ? t,s,hb_ASCIILower(Upper("xyz")),hb_ASCIILower("A"+"B")
 NEXT
 ? Probe("AZ"),s,hb_ASCIILower(hb_ASCIIUpper("aBc"))
RETURN
FUNCTION Probe(s)
RETURN hb_ASCIILower(s)
