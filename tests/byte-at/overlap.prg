PROCEDURE Main()
 LOCAL s:="ABABABAB",n:="BAB",i:=0
 FOR i:=0 TO 30
 ? hb_BAt(n,s),hb_BAt(s,n)
 s+="ABA"
 NEXT
 ? hb_BAt("Z","AAAAZ"),hb_BAt("AAAAAA","AAAAA"),hb_BAt("AAAAB","AAAAAAAAAB")
RETURN
