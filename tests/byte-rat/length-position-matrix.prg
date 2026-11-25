PROCEDURE Main()
 LOCAL s:="",n:="",i:=0,j:=0,c:=0
 FOR i:=0 TO 33
 FOR j:=-36 TO 36
 FOR c:=0 TO 7
 n:=hb_BSubStr(s,j,c)
 ? hb_BRAt(n,s)
 NEXT
 NEXT
 s+="A"+Chr(0)+"éABA"
 NEXT
RETURN
