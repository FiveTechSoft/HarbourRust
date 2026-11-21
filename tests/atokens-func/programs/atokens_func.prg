function main()
 local a := hb_ATokens("a,b,c", ",")
 local b := hb_ATokens("a,,c", ",")
 local c := hb_ATokens(",a,", ",")
 local d := hb_ATokens("abc")
 local e := hb_ATokens("")
 local f := hb_ATokens("a::b::c", "::")
 local g := hb_ATokens("abc", ",")
 local h := hb_ATokens("x,y", "")
 local i := hb_ATokens("uno dos tres")
 ? Len(a), "[" + a[1] + "]", "[" + a[2] + "]", "[" + a[3] + "]"
 ? Len(b), "[" + b[1] + "]", "[" + b[2] + "]", "[" + b[3] + "]"
 ? Len(c), "[" + c[1] + "]", "[" + c[2] + "]", "[" + c[3] + "]"
 ? Len(d), "[" + d[1] + "]"
 ? Len(e), "[" + e[1] + "]"
 ? Len(f), "[" + f[1] + "]", "[" + f[2] + "]", "[" + f[3] + "]"
 ? Len(g), "[" + g[1] + "]"
 ? Len(h), "[" + h[1] + "]"
 ? Len(i), "[" + i[1] + "]"
return nil
