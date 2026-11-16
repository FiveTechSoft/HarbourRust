PROCEDURE Main()
   dbUseArea(.T.,"DBFCDX","clie.dbf","CLIE",.T.,.T.)
   dbGoTop()
   DO WHILE !Eof()
      ? RecNo(), EDAD, CLIE->SALDO, FIELD->ACTIVO, ALTA, NOTA, NOMBRE, "|"
      dbSkip()
   ENDDO
   ? Eof(), Bof(), LastRec()
   dbCloseArea()
RETURN
