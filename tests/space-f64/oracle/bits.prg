procedure Main()
local bits,n
for each bits in {"c3e0000000000001","c3e0000000000000","c3dfffffffffffff","43dfffffffffffff","43e0000000000000","43e0000000000001","7ff0000000000000","fff0000000000000","7ff8000000000000","0000000000000001","8000000000000001"}
n:=FromHex(bits)
OutStd(hb_jsonEncode({bits,CountMeta(n)}),Chr(10))
next
return
