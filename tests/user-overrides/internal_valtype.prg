function Main()
local a := { "x", 7 }, s := "x", n := 7, u := NIL, l := .T.
? ValType("x"), Descend(3), Time()
? HB_ISCHAR(s), HB_ISCHAR(n), HB_ISCHAR(u), HB_ISCHAR(l)
? HB_ISNIL(u), HB_ISLOGICAL(l)
? HB_ISSTRING(a[1]), HB_ISSTRING(a[2])
return nil

function ValType(x)
return "USER"

function Descend(n)
return n * 10

function Time()
return "T"
