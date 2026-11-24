// Own MIT. Scalar tags and explicit name case ignore local shadows.
MEMVAR value
PROCEDURE SetValue(x)
 PUBLIC value:=x
RETURN
PROCEDURE Read()
 LOCAL value:="local",x:=NIL
 SetValue(17)
 x:=m->VaLuE
 ? value,x
 SetValue(.T.)
 x:=MEMVAR->VALUE
 ? value,x
 SetValue(NIL)
 x:=M->value
 ? value,ValType(x)
 SetValue(19.25)
 x:=M->value
 SetValue(23.5)
 ? x,M->value
RETURN
PROCEDURE Main()
 Read()
RETURN
