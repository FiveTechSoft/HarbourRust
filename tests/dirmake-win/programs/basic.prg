function main()
local n := 0
? DIRMAKE("new"), DIRMAKE("new"), DIRMAKE("missing/leaf"), DIRMAKE(""), DIRMAKE(".")
? DIRMAKE("plainfile"), DIRMAKE("plainfile/leaf"), DIRMAKE("parent"), DIRMAKE("parent\child")
? DIRMAKE(), DIRMAKE(NIL), DIRMAKE(7), DIRMAKE(.t.)
? DIRMAKE("nul"+Chr(0)+"tail"), DIRMAKE("nul")
return nil
function bump(n)
n++
return "ignored"
