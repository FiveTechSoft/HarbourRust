function main()
 local a := hb_ATokens("a  b   c")
 local b := hb_ATokens("  x y  ")
 local c := hb_ATokens("a,,b", ",")
 local d := hb_ATokens("a;  b", "; ")
 ? Len(a), "[" + a[1] + "]", "[" + a[2] + "]", "[" + a[3] + "]"
 ? Len(b), "[" + b[1] + "]", "[" + b[2] + "]"
 ? Len(c), "[" + c[1] + "]", "[" + c[2] + "]", "[" + c[3] + "]"
 ? Len(d), "[" + d[1] + "]", "[" + d[2] + "]"
return nil
