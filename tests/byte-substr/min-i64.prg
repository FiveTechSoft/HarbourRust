PROCEDURE Main()
 LOCAL s:="abc",n:=-9223372036854775807,c:=-9223372036854775807
 n-=1
 c-=1
 ? n,c
 ? hb_StrToHex(hb_BSubStr(s,n))
 ? hb_StrToHex(hb_BSubStr(s,n,2))
 ? hb_StrToHex(hb_BSubStr(s,1,c))
RETURN
