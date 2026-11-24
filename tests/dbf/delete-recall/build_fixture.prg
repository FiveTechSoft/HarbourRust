REQUEST DBFNTX
procedure Main()
local aStruct := {{"KEY","C",6,0},{"NAME","C",20,0},{"AMOUNT","N",10,2},{"FLAG","L",1,0},{"FECHA","D",8,0}}
dbCreate("del_rec.dbf", aStruct, "DBFNTX")
dbCloseArea()
dbUseArea(.T.,"DBFNTX","del_rec.dbf","DEL",.F.,.F.)
append blank
FieldPut(1,"000004"); FieldPut(2,"Diaz, Ana");    FieldPut(3,12.50);  FieldPut(4,.T.); FieldPut(5,CToD("20260110"))
append blank
FieldPut(1,"000001"); FieldPut(2,"Alba, Bea");    FieldPut(3,3.25);   FieldPut(4,.F.); FieldPut(5,CToD("20260105"))
append blank
FieldPut(1,"000007"); FieldPut(2,"Cid, Carlos");  FieldPut(3,90.00);  FieldPut(4,.T.); FieldPut(5,CToD("20260202"))
index on KEY to del_tag.ntx
index on KEY to del_tag.ntx
? "built", LastRec()
dbCloseArea()
return
