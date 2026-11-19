function Main()
dbUseArea(.T.,"DBFNTX","goto_set.dbf","GOTO",.F.,.F.)
? "fcount:", FCount(), "lastrec:", LastRec()
? "names:", FieldGet(1), FieldGet(2)
? "fechas:", FieldGet(5)
dbCloseArea()
return nil
