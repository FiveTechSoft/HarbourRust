PROCEDURE Main()
 LOCAL s:="á"+Chr(0)+"路径Z",n:=0
 n:=-9223372036854775807
 ? hb_StrToHex(hb_BLeft(s,n)),hb_StrToHex(hb_BRight(s,n))
 n:=-100
 ? hb_StrToHex(hb_BLeft(s,n)),hb_StrToHex(hb_BRight(s,n))
 n:=-4
 ? hb_StrToHex(hb_BLeft(s,n)),hb_StrToHex(hb_BRight(s,n))
 n:=-1
 ? hb_StrToHex(hb_BLeft(s,n)),hb_StrToHex(hb_BRight(s,n))
 n:=0
 ? hb_StrToHex(hb_BLeft(s,n)),hb_StrToHex(hb_BRight(s,n))
 n:=1
 ? hb_StrToHex(hb_BLeft(s,n)),hb_StrToHex(hb_BRight(s,n))
 n:=2
 ? hb_StrToHex(hb_BLeft(s,n)),hb_StrToHex(hb_BRight(s,n))
 n:=3
 ? hb_StrToHex(hb_BLeft(s,n)),hb_StrToHex(hb_BRight(s,n))
 n:=4
 ? hb_StrToHex(hb_BLeft(s,n)),hb_StrToHex(hb_BRight(s,n))
 n:=8
 ? hb_StrToHex(hb_BLeft(s,n)),hb_StrToHex(hb_BRight(s,n))
 n:=100
 ? hb_StrToHex(hb_BLeft(s,n)),hb_StrToHex(hb_BRight(s,n))
 n:=9223372036854775807
 ? hb_StrToHex(hb_BLeft(s,n)),hb_StrToHex(hb_BRight(s,n))
 ? hb_BLeft("",1),hb_BRight("",1)
RETURN
