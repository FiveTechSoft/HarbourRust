REQUEST DBFNTX
procedure Main()
local aStruct := {{"KEY","C",6,0},{"NAME","C",20,0},{"AMOUNT","N",10,2},{"FLAG","L",1,0},{"FECHA","D",8,0}}
dbCreate("goto_set.dbf", aStruct, "DBFNTX")
dbCloseArea()
dbUseArea(.T.,"DBFNTX","goto_set.dbf","GOTO",.F.,.F.)
append blank
FieldPut(1,"000004"); FieldPut(2,"Diaz, Ana");    FieldPut(3,12.50);  FieldPut(4,.T.); FieldPut(5,CToD("20260110"))
append blank
FieldPut(1,"000001"); FieldPut(2,"Alba, Bea");    FieldPut(3,3.25);   FieldPut(4,.F.); FieldPut(5,CToD("20260105"))
append blank
FieldPut(1,"000007"); FieldPut(2,"Cid, Carlos");  FieldPut(3,90.00);  FieldPut(4,.T.); FieldPut(5,CToD("20260202"))
append blank
FieldPut(1,"000002"); FieldPut(2,"Duarte, Eva");  FieldPut(3,7.75);   FieldPut(4,.F.); FieldPut(5,CToD("20260120"))
append blank
FieldPut(1,"000006"); FieldPut(2,"Estrada, Fab"); FieldPut(3,44.10);  FieldPut(4,.T.); FieldPut(5,CToD("20260131"))
append blank
FieldPut(1,"000003"); FieldPut(2,"Flores, Gil");  FieldPut(3,0.00);   FieldPut(4,.F.); FieldPut(5,CToD("20260122"))
append blank
FieldPut(1,"000005"); FieldPut(2,"Guzman, Hda");  FieldPut(3,31.00);  FieldPut(4,.T.); FieldPut(5,CToD("20260125"))
index on KEY to goto_set.ntx
? "built", LastRec(), ordSetFocus("goto_set")
dbCloseArea()
return
