PROCEDURE Main()
   dbUseArea(.T.,"DBFCDX","clie.dbf","CLIE",.F.,.F.)
   Grabar()
RETURN

PROCEDURE Grabar()
   FieldPut(1, 5)
RETURN
