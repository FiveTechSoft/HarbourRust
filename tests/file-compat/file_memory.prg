procedure Exercise()
local a := NIL
local s := "Exact.TXT" + ""
File(Substr("_Exact.TXT",2))
File(s)
a := "Exact.TXT"
File(a)
a := 2.5
File(a)
set default to (Substr("_default",2))
a := "search"
set path to (a)
File("path.txt")
a := NIL
set path to (a)
return
procedure Main()
Exercise()
? hb_MemCheck()
return
