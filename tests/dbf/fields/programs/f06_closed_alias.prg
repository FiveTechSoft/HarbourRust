PROCEDURE Main()
   dbUseArea(.T.,"DBFCDX","fields.dbf","CLIE",.F.,.F.)
   dbCloseArea()
   ? CLIE->EDAD
RETURN
