PROCEDURE Main()
 LOCAL s:="a"+Chr(0)+"é",v:=NIL
 FOR EACH v IN s
 ? ValType(v)
 ? IIf(v:__enumIsFirst,"first","other")
 ? IIf(Asc(v)==0,"nul",v)
 NEXT
RETURN
