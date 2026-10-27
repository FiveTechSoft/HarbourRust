function main()
local s := AllTrim(" abc "), b := {|n| OutStd("x"), n+1}
local a := { "str  " }, d := { "dyn  " }
OutStd(s, a[1], d[1], "  ")
? Len(s), Len(a), Len(d)
? Eval(b, 3)
If(.T., OutStd("T"), OutStd("F"))
(OutStd("A"), OutStd("B"))
? 1
return
