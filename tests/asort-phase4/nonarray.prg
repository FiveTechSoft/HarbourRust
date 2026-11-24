FUNCTION Main()
 LOCAL i
 FOR i:=1 TO 317
  ASort(Replicate("word",31),Replicate("extra",17))
 NEXT
 ? ValType(ASort("text")),ValType(ASort(NIL)),ValType(ASort(12))
RETURN NIL
