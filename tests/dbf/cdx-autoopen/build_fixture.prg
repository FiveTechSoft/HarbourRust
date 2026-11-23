REQUEST DBFCDX
procedure Main()
local i, k := {"C003","C001","C002"}
rddSetDefault("DBFCDX")
/* auto_s: structural bag auto_s.cdx (production flag set by ordCreate) */
dbCreate("auto_s.dbf", {{"CCOD","C",10,0},{"NINT","N",4,0}})
dbUseArea(.T.,, "auto_s.dbf", "S", .F., .F.)
for i := 1 to 3
   dbAppend()
   S->CCOD := k[i]
   S->NINT := i
next
ordCreate("auto_s.cdx", "CCOD", "CCOD")
dbCloseArea()
/* auto_n: same data, own bag; check_cdx_autoopen.py clears byte 28 */
dbCreate("auto_n.dbf", {{"CCOD","C",10,0},{"NINT","N",4,0}})
dbUseArea(.T.,, "auto_n.dbf", "N", .F., .F.)
for i := 1 to 3
   dbAppend()
   N->CCOD := k[i]
   N->NINT := i
next
ordCreate("auto_n.cdx", "CCOD", "CCOD")
dbCloseArea()
? "built"
return
