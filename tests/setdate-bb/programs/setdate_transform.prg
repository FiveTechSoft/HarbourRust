function main()
 local d := CToD("12/25/2026")
 set century on
 ? "[" + DToC(d) + "]"
 ? "[" + Transform(d, "@D") + "]"
 set date italian
 ? "[" + Transform(d, "") + "]"
 set century off
 ? "[" + DToC(d) + "]"
 ? d
 ? "[" + DToS(d) + "]"
return nil
