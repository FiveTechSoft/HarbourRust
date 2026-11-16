PROCEDURE Main()
   LOCAL nombre := "local wins"
   dbUseArea(.T.,"DBFCDX","fields.dbf","CLIE",.F.,.F.)
   ? nombre, CLIE->NOMBRE, "|"
   ? Edad(), Twice(), "|"
   dbCloseArea()
RETURN
FUNCTION Edad()
RETURN EDAD
FUNCTION Twice()
   LOCAL edad := 2
RETURN edad * EDAD
