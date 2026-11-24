REQUEST DBFNTX
REQUEST DBFCDX
procedure Main()
local i
dbCreate("ixwrite.dbf", {{"KEY","C",6,0},{"NAME","C",10,0}}, "DBFNTX")
dbCloseArea()
dbUseArea(.T.,"DBFNTX","ixwrite.dbf","IXW",.F.,.F.)
for i := 1 to 8
 append blank
 FieldPut(1, "K" + StrZero(i, 5))
 FieldPut(2, "N" + StrZero(i, 3))
next
index on KEY to ixwrite.ntx
? "built", LastRec()
dbCloseArea()
dbCreate("ixw_cdx.dbf", {{"KEY","C",6,0},{"NAME","C",10,0}}, "DBFCDX")
dbCloseArea()
dbUseArea(.T.,"DBFCDX","ixw_cdx.dbf","IXC",.F.,.F.)
for i := 1 to 8
 append blank
 FieldPut(1, "K" + StrZero(i, 5))
next
index on KEY to ixw_tag.cdx
dbCloseArea()
return
