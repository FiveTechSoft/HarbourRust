request DBFCDX
function ReadCycle()
local value
local i
 dbUseArea(.T.,"DBFCDX","cdxprobe.dbf","P",.F.,.T.)
 OrdListAdd("names.cdx")
 for i:=1 to 30
  value:=FieldGet(1)
  dbSkip()
 next
 OrdListClear()
 dbCloseArea()
 return nil
function Main()
 local i
 for i:=1 to 100
  ReadCycle()
 next
 ? hb_memcheck()
 return nil
