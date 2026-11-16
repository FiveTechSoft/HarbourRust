PROCEDURE Main()
   LOCAL n := 0
   dbUseArea(.T.,"DBFNTX","clin.dbf","CLIN",.F.,.F.)
   dbGoTo(2)
   FIELD->NOMBRE := "Luis Mod"
   CLIN->EDAD := 46
   FIELD->SALDO := 10.25
   CLIN->ACTIVO := .T.
   CLIN->ALTA := SToD("20260301")
   dbAppend()
   _FIELD->NOMBRE := "ZACARIAS"
   FIELD->EDAD := EDAD + 3
   CLIN->SALDO := CLIN->EDAD * 2
   ordCreate("clin_nom", "clin_nom", "NOMBRE")
   ? dbSeek("Luis"), Found(), RecNo(), EDAD, SALDO, ACTIVO, ALTA, "|"
   ? dbSeek("XX"), Found(), Eof(), "|"
   dbGoTop()
   DO WHILE !Eof()
      n := n + EDAD
      ? RecNo(), EDAD, SALDO, "|"
      dbSkip()
   ENDDO
   ? n
   dbCloseArea()
RETURN
