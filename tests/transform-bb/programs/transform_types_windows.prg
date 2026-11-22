function main()
 local d := CToD("12/25/2026")
 local b := Transform(.T., "@L Y/N")
 local s := Transform("hello", "@!")
 local c := Transform(d, "@D")
 ? "[" + c + "]"
 ? "[" + b + "]"
 ? "[" + s + "]"
return nil
