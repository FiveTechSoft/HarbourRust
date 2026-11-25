PROCEDURE Main()
 LOCAL s:="",i:=0,k:=0
 FOR i:=0 TO 255
 s+=Chr(i)
 NEXT
 FOR i:=-258 TO 258
 ? i,hb_StrToHex(hb_BSubStr(s,i)),hb_StrToHex(hb_BSubStr(s,i,1)),hb_StrToHex(hb_BSubStr(s,i,17))
 NEXT
RETURN
