REQUEST DBFCDX
function Main()
dbUseArea(.T.,"DBFNTX","fixture.dbf","DATA",.F.,.F.)
? RecNo(),LastRec(),Bof(),Eof()
? FieldGet(1),FieldGet(2)
dbCloseArea()
dbUseArea(.T.,"DBFCDX","fixture.dbf","DATA",.F.,.F.)
? RecNo(),LastRec()
? FieldGet(1),FieldGet(5)
dbCloseArea()
return nil
