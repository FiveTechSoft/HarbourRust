REQUEST DBFNTX
procedure Main()
local a:={{"V","N",10,2},{"W","N",8,0},{"X","N",8,3}}
RddSetDefault("DBFNTX")
dbCreate("round.dbf",a,"DBFNTX")
dbUseArea(.T.,"DBFNTX","round.dbf","R",.F.,.F.)
RPut({2.685, 2.665, 2.695, 0.125, 0.5, 1.5, 2.5, 1.005, 2.675, -2.675, -0.0, 9999.999, 0.0005, 0.045, 0.055})
dbCloseArea()
return nil

procedure RPut(vals)
local i
for i:=1 to len(vals)
   dbAppend()
   FieldPut(1, vals[i])
next
/* W (dec 0) and X (dec 3) extras */
dbAppend(); FieldPut(2, 0.5)
dbAppend(); FieldPut(2, 1.5)
dbAppend(); FieldPut(2, 2.5)
dbAppend(); FieldPut(2, 3.5)
dbAppend(); FieldPut(2, -0.5)
dbAppend(); FieldPut(2, -1.5)
dbAppend(); FieldPut(2, -2.5)
dbAppend(); FieldPut(3, 0.0005)
dbAppend(); FieldPut(3, 0.0015)
dbAppend(); FieldPut(3, 0.0025)
return
