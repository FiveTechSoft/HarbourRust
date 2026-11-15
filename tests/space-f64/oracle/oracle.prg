procedure Main()
local n,s
for each n in {-3.9,-1.9,-1.0,-0.9,-0.0,0.0,0.1,0.9,1.0,1.1,1.9,2.9,8.99,65535.9,65536.9,65537.9}
s:=Space(n)
OutStd(hb_jsonEncode({n,CountMeta(n),Len(s),Asc(s),Asc(Right(s,1))}),Chr(10))
next
for each n in {-9223372036854777856.0,-9223372036854775808.0,-9223372036854774784.0,9223372036854774784.0,9223372036854775808.0,10.0^100,-10.0^100,Special(1),Special(2),Special(3)}
OutStd(hb_jsonEncode({"conversion-only",CountMeta(n)}),Chr(10))
next
return
