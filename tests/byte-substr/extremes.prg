PROCEDURE Main()
 LOCAL s:="abc",n:=0,k:=0
 n:=-9223372036854775807
 ? hb_StrToHex(hb_BSubStr(s,n)),hb_StrToHex(hb_BSubStr(s,n,2))
 n:=9223372036854775807
 ? hb_StrToHex(hb_BSubStr(s,n)),hb_StrToHex(hb_BSubStr(s,n,2))
 n:=1
 k:=9223372036854775807
 ? hb_StrToHex(hb_BSubStr(s,n,k))
 k:=-9223372036854775807
 ? hb_StrToHex(hb_BSubStr(s,n,k))
 ? hb_BSubStr("",1),hb_BSubStr("",-1,10)
RETURN
