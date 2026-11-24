// Own MIT. Lookup result survives replacement and private shadow unwind.
MEMVAR value
PROCEDURE SetValue(x)
 PUBLIC value:=x
RETURN
PROCEDURE Read()
 LOCAL old:=NIL,i:=0
 FOR i:=1 TO 117
  SetValue("old")
  old:=M->value
  SetValue("new")
  ? old,MEMVAR->value
 NEXT
RETURN
PROCEDURE Main()
 SetValue("initial")
 Read()
RETURN
