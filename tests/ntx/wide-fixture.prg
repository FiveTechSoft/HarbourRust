request DBFNTX
function Main()
   local i
   dbCreate("wide", {{"NAME","C",255,0}}, "DBFNTX")
   dbUseArea(.T.,"DBFNTX","wide.dbf","W",.F.,.F.)
   for i := 1 to 250
      dbAppend()
      FieldPut(1,"K"+StrZero((i*37)%71,3))
   next
   OrdCreate("wide.ntx","WIDE","NAME",{||FieldGet(1)})
   dbCloseArea()
return nil
