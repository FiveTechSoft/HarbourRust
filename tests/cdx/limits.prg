request DBFCDX
function Main()
   dbCreate("wide255", {{"NAME","C",255,0}}, "DBFCDX")
   dbUseArea(.T.,"DBFCDX","wide255.dbf","W",.F.,.F.)
   dbAppend()
   FieldPut(1,"TEST")
   OrdCreate("wide255keys.cdx","WIDE255","NAME",{||FieldGet(1)})
   dbCloseArea()
return nil
