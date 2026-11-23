REQUEST DBFCDX
procedure Main()
local i, k := {"C003","C001","C002"}
rddSetDefault("DBFCDX")
/* shr: plain table, no bag */
dbCreate("shr.dbf", {{"CCOD","C",10,0},{"NINT","N",4,0}})
dbUseArea(.T.,, "shr.dbf", "SR", .F., .F.)
for i := 1 to 3
   dbAppend()
   SR->CCOD := k[i]
   SR->NINT := i
next
dbCloseArea()
/* shc: same data with a structural bag shc.cdx */
dbCreate("shc.dbf", {{"CCOD","C",10,0},{"NINT","N",4,0}})
dbUseArea(.T.,, "shc.dbf", "SC", .F., .F.)
for i := 1 to 3
   dbAppend()
   SC->CCOD := k[i]
   SC->NINT := i
next
ordCreate("shc.cdx", "CCOD", "CCOD")
dbCloseArea()
? "built"
return
