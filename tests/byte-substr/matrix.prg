PROCEDURE Main()
 LOCAL s:="A"+Chr(0)+"éZ",i:=0,n:=0
 FOR i:=-8 TO 8
 ? i,hb_StrToHex(hb_BSubStr(s,i))
 FOR n:=-2 TO 8
 ? i,n,hb_StrToHex(hb_BSubStr(s,i,n))
 NEXT
 NEXT
RETURN
