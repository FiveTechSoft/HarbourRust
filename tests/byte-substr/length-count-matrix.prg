PROCEDURE Main()
 LOCAL s:="",i:=0,j:=0,k:=0,c:=0,n:=0
 FOR n:=0 TO 11
 s:=""
 FOR i:=1 TO n
 s+="A"+Chr(0)+"é"
 NEXT
 FOR j:=-48 TO 48
 ? n,j,hb_StrToHex(hb_BSubStr(s,j))
 FOR c:=-2 TO 48
 ? n,j,c,hb_StrToHex(hb_BSubStr(s,j,c))
 NEXT
 NEXT
 NEXT
RETURN
