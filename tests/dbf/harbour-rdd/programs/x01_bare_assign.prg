// expect-reject: assigns an undeclared name
// Harbour 3.2 stores a bare undeclared assignment in a memvar, not in the
// field (Harbour side of this case: the field is unchanged); hbc rejects it.
PROCEDURE Main()
   dbUseArea(.T.,"DBFNTX","clin.dbf","CLIN",.F.,.F.)
   NOMBRE := "CAMBIADO"
   ? CLIN->EDAD, FIELD->NOMBRE == "ANA", "|"
   dbCloseArea()
RETURN
