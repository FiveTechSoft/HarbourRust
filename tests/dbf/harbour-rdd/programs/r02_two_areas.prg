PROCEDURE Main()
   dbUseArea(.T.,"DBFCDX","clie.dbf","CLIE",.F.,.T.)
   dbUseArea(.T.,"DBFNTX","clin.dbf","CLIN",.F.,.T.)
   dbGoTo(2)
   ? RecNo(), CLIN->NOMBRE, CLIE->NOMBRE, CLIE->EDAD + CLIN->EDAD, "|"
   ? EDAD, NOMBRE, "|"
   dbCloseArea()
   ? CLIE->EDAD, NOMBRE, "|"
   dbCloseArea()
RETURN
