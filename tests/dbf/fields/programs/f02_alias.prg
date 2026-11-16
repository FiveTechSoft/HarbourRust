PROCEDURE Main()
   dbUseArea(.T.,"DBFNTX","fields.dbf","Clie",.F.,.T.)
   ? clie->nombre, Field->EDAD, CLIE->Saldo, _FIELD->activo, cLiE->ALTA, "|"
   dbSkip()
   ? CLIE->NOMBRE, clie->edad, "|"
   dbCloseArea()
RETURN
