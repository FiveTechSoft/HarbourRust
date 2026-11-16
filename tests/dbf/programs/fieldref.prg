REQUEST DBFCDX
function Main()
dbUseArea(.T.,"DBFCDX","M_CLIE.DBF","CLIE",.F.,.F.)
? CLIENTE
? CODIGO
? FieldGet(1),FieldGet(2)
dbSkip()
? cliente,Codigo
? RecNo(),LastRec(),Eof()
dbCloseArea()
dbUseArea(.T.,"DBFCDX","M_CLIE.DBF","CLIE",.F.,.T.)
? CLIENTE
dbCloseArea()
return nil
