PROCEDURE Main()
   dbUseArea(.T.,"DBFCDX","clie.dbf","CLIE",.F.,.F.)
   dbUseArea(.T.,"DBFNTX","clin.dbf","CLIN",.F.,.F.)
   dbAppend()
   FIELD->NOMBRE := "SIN CERRAR"
   CLIE->EDAD := 99
   ? LastRec(), "|"
RETURN
