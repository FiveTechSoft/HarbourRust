function main()
local i, a := {}
for i := 1 to 8
AAdd(a, DIRMAKE("h"+Chr(127+i*16)))
next
? a[1],a[2],a[3],a[4]
? a[5],a[6],a[7],a[8]
? DIRMAKE("A"+Chr(128)), DIRMAKE("B"+Chr(255)), DIRMAKE("C"+Chr(1)), DIRMAKE("D"+Chr(127)), DIRMAKE(Chr(195)+Chr(169))
? DIRMAKE(Replicate("x",200)), DIRMAKE(Replicate("y",255)), DIRMAKE(Replicate("z",256)), DIRMAKE(Replicate("w",259)), DIRMAKE(Replicate("v",260))
? DIRMAKE(Replicate("n/",130)), DIRMAKE("u"+Chr(0)), DIRMAKE(Chr(0)), DIRMAKE("a|b"), DIRMAKE('q"r'), DIRMAKE("l<m")
return nil
