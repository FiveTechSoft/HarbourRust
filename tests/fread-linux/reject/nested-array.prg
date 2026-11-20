FUNCTION Handle(p)
 AAdd(p,1)
RETURN -1
FUNCTION Main()
 LOCAL p:={},s:="keep"
 AAdd(p,3)
 ? FRead(Handle(p),@s,2)
 ? Len(p)
RETURN NIL
