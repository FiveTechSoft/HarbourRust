request DBFCDX
function Main()
   local i
   dbCreate("wide", {{"NAME","C",240,0}}, "DBFCDX")
   dbUseArea(.T.,"DBFCDX","wide.dbf","W",.F.,.F.)
   for i := 1 to 250
      dbAppend()
      FieldPut(1,"K"+StrZero((i*37)%71,3))
   next
   OrdCreate("widekeys.cdx","WIDE","NAME",{||FieldGet(1)})
   dbCloseArea()
return nil
