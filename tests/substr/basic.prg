function Main()
local s := "ABCDE"
local t:=SubStr(s,1)
? "["+SubStr(s,1)+"]", "["+SubStr(s,0,2)+"]"
? "["+SubStr(s,-2)+"]", "["+SubStr(s,-99,3)+"]"
? "["+SubStr(s,6)+"]", "["+SubStr(s,2,0)+"]", "["+SubStr(s,2,-1)+"]"
? s, ValType(t), Len(SubStr(s,1,99))
return nil
