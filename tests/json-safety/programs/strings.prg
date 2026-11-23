function Main()
local s := hb_jsonDecode('"short"')
local e := hb_jsonDecode('""')
local a := hb_jsonDecode('"\u0041Z"')
local long := Replicate("x", 1000)
local encoded := hb_jsonEncode(long)
local decoded := hb_jsonDecode(encoded)
local escapes := hb_jsonDecode('"' + Replicate('\n', 1000) + '"')
? s == "short", Len(e), a == "AZ"
? Len(encoded), Len(decoded), decoded == long
? Len(escapes)
? hb_jsonEncode(s), hb_jsonEncode(e), hb_jsonEncode(a)
return nil
