FUNCTION Take(p)
 AAdd(p,2)
RETURN "x"
FUNCTION Main()
 LOCAL a:={}
 AAdd(a,3)
 ? FWrite(-1,Take(a))
 ? Len(a)
RETURN NIL
