REQUEST DBFNTX
function Main()
dbCreate("widths.dbf",{{"A","N",6,0},{"B","N",10,0},{"C","N",10,2}},"DBFNTX")
dbUseArea(.T.,"DBFNTX","widths.dbf","WIDTHS",.F.,.F.)
dbAppend()
FieldPut(1,42)
FieldPut(2,42)
FieldPut(3,42.00)
dbCloseArea()
return nil
