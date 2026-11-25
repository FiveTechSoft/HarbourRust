PROCEDURE Main()
 LOCAL s:="ABABABAB",n:="BAB",i:=0
 FOR i:=0 TO 30
 ? hb_BRAt(n,s),hb_BRAt(s,n)
 s+="ABA"
 NEXT
 ? hb_BRAt("Z","AAAAZ"),hb_BRAt("AAAAAA","AAAAA"),hb_BRAt("AAAAB","AAAAAAAAAB")
RETURN
