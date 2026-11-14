function Main()
dbUseArea(.T.,"DBFNTX","fixture.dbf","DATA",.F.,.T.)
? RecNo(),LastRec(),Bof(),Eof()
? FieldGet(1),FieldGet(2),FieldGet(3),FieldGet(4),FieldGet(5)
dbSkip()
? RecNo(),FieldGet(1),Deleted()
dbCloseArea()
return nil
