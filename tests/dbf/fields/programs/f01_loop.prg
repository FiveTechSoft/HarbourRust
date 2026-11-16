PROCEDURE Main()
   dbUseArea(.T.,"DBFCDX","fields.dbf","CLIE",.F.,.F.)
   dbGoTop()
   DO WHILE !Eof()
      ? RecNo(), NOMBRE, EDAD, SALDO, ACTIVO, ALTA, "|"
      dbSkip()
   ENDDO
   ? EDAD, SALDO, ACTIVO, ALTA, Eof(), "|"
   dbCloseArea()
RETURN
