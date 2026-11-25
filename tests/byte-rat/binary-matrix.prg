PROCEDURE Main()
 LOCAL i:=0,j:=0,n:="",s:=""
 FOR i:=0 TO 255
 n:=Chr(i)
 FOR j:=0 TO 255
 s:=Chr(j)
 ? hb_BRAt(n,s)
 NEXT
 NEXT
RETURN
