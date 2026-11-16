// A local initialised as an integer receives a decimal field and
// arithmetic over fields (issue #1 x7: `n := T->NDEC * 2`).
PROCEDURE Main()
   LOCAL n := 0, m := 0, k := 0
   dbUseArea(.T.,"DBFCDX","fields.dbf","CLIE",.F.,.F.)
   DO WHILE ! Eof()
      n := CLIE->SALDO * 2
      m := SALDO
      k := EDAD + SALDO
      ? n, m, k, n + 1, "|"
      dbSkip()
   ENDDO
   n := EDAD
   ? n, "|"
   dbCloseArea()
RETURN
