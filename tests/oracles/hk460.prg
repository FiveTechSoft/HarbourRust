procedure main()
local a := { 1 }, h := { "key" => 2 }, s := "tail  "
OutStd("[", "a  ")
OutStd("]", "   ")
OutStd("[", 7, .T., NIL, 1.25, a, h, "]")
OutStd()
OutStd("[", ValType(OutStd("N")), "]")
OutStd("[", Side("A"), Side("B"), "]")
OutStd("[", s, "]")
OutStd("[", AllTrim(" tmp "), "]")
return
function Side(s)
OutStd(s)
return s
