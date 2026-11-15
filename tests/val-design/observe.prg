procedure Main()
local cases:={""," ","   ","0","1","01","+1","-1","-0"," 1","1 ","         1","1.20"," 1.20","1.2xyz","abc.def","1e3","0x10",".","+.5","-.5","12abc","12.3.4","9007199254740993","9223372036854775807","9223372036854775808","-9223372036854775808","999999999999999999999","0.00000000000000001"}
local s,v,m
for each s in cases
v:=Val(s)
m:={s,NumMeta(v),Str(v),Transform(v,"999999999999999999999.99999"),hb_BitAnd(v,255),NumMeta(v+0),Str(v+0),NumMeta(v*1),Str(v*1)}
OutStd(hb_jsonEncode(m),Chr(10))
next
return
