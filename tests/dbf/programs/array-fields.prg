function Main()
local a:= Array(3)
 dbUseArea(.T.,"DBFNTX","fixture.dbf","T",.F.,.T.)
 a[1]:=FieldGet(2)
 a[2]:=FieldGet(5)
 a[3]:=FieldGet(4)
 ? a[1],a[2],a[3]
 ? ValType(a[1]),ValType(a[2]),ValType(a[3])
 ? HB_ISNUMERIC(a[1]),HB_ISNUMERIC(a[2]),HB_ISNUMERIC(a[3])
 dbSkip(100)
 a[1]:=FieldGet(2)
 a[2]:=FieldGet(5)
 a[3]:=FieldGet(4)
 ? a[1],a[2],a[3]
 ? a[2]
 ? a[2],"END"
 ? Empty(a[1]),Empty(a[2]),Empty(a[3])
 ? HB_ISNUMERIC(a[1]),HB_ISNUMERIC(a[2]),HB_ISNUMERIC(a[3])
 dbCloseArea()
 return nil
