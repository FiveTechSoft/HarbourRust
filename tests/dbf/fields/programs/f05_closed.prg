PROCEDURE Main()
   dbUseArea(.T.,"DBFCDX","fields.dbf","CLIE",.F.,.F.)
   ? EDAD, "|"
   dbCloseArea()
   ? NOMBRE
RETURN
