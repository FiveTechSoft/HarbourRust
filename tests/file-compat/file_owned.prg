procedure Main()
local a := NIL
local s := "Exact.TXT"
? "owned",File(Substr("_Exact.TXT",2)),File(Upper("exact.txt")),File(s)
a := "Exact.TXT"
? "dynstr",File(a)
a := 19
? "dynint",File(a)
a := .T.
? "dynbool",File(a)
a := 2.5
? "dynfloat",File(a)
a := NIL
? "dynnil",File(a)
set default to (Substr("_default",2))
? "set-owned",File("only.txt")
a := "search"
set path to (a)
? "dynpath",File("path.txt")
a := 19
set default to (a)
? "set-ignore",File("only.txt")
a := NIL
set default to (a)
? "set-nil",File("Exact.TXT")
return
