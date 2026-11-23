function main()
 local d := CToD("12/25/2026")
 ? "[" + DToC(d) + "]"
 set century on
 ? "[" + DToC(d) + "]"
 set date italian
 ? "[" + DToC(d) + "]"
 set century off
 ? "[" + DToC(d) + "]"
 set date german
 ? "[" + DToC(d) + "]"
 set date to ansi
 ? "[" + DToC(d) + "]"
 set date usa
 ? "[" + DToC(d) + "]"
 set date japanese
 ? "[" + DToC(d) + "]"
 set date british
 ? "[" + DToC(d) + "]"
 set date french
 ? "[" + DToC(d) + "]"
 set date american
 ? "[" + DToC(d) + "]"
 ? Date()
 ? DToS(d)
return nil
