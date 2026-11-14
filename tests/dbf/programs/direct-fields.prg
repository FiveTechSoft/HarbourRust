function Main()
 dbUseArea(.T.,"DBFNTX","fixture.dbf","T",.F.,.T.)
 ? FieldGet(1)==FieldGet(1),FieldGet(5)==FieldGet(5),FieldGet(2)==FieldGet(2)
 ? FieldGet(1)=="alpha","alpha"==FieldGet(1)
 ? FieldGet(1)!=FieldGet(1),FieldGet(1)<"z","a"<FieldGet(1)
 ? FieldGet(2)<FieldGet(2),FieldGet(2)>=FieldGet(2)
 dbCloseArea()
 return nil
