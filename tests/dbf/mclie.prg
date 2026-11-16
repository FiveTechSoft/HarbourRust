REQUEST DBFCDX
function Main()
dbCreate("M_CLIE.DBF",{{"CLIENTE","C",40,0},{"CODIGO","N",6,0}},"DBFCDX")
dbUseArea(.T.,"DBFCDX","M_CLIE.DBF","CLIE",.F.,.F.)
dbAppend()
FieldPut(1,"ANTONIO")
FieldPut(2,7)
dbAppend()
FieldPut(1,"FIVETECH")
FieldPut(2,8)
dbCloseArea()
return nil
