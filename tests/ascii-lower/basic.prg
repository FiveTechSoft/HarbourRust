PROCEDURE Main()
 LOCAL s:="",i:=0
 FOR i:=0 TO 255
 s+=Chr(i)
 NEXT
 ? hb_StrToHex(hb_ASCIILower(s))
 ? hb_StrToHex(hb_ASCIILower("AZazÁÑ路径"+Chr(0)+"AZ"))
 ? hb_ASCIILower(""),hb_ASCIILower("0123!?[AZ]"),Len(hb_ASCIILower(Replicate("A",4097)))
RETURN
