REQUEST DBFCDX
function Main()
dbUseArea(.T.,"DBFCDX","mclie_real.dbf","CLIE",.F.,.F.)
? RecNo(),LastRec()
? CLIENTE
? NOMBRE
? SALDO
? ALTA
? DIAS
? FieldGet(1),FieldGet(3)
dbSkip()
? CLIENTE
dbGoBottom()
? CLIENTE
? NOMBRE
dbCloseArea()
return nil
