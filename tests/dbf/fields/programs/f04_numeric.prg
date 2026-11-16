PROCEDURE Main()
   dbUseArea(.T.,"DBFCDX","fields.dbf","CLIE",.F.,.F.)
   ? EDAD + 1, EDAD * 2, EDAD > 40, EDAD == 34, Empty(EDAD), ValType(NOMBRE), "|"
   dbSkip(2)
   ? EDAD, Empty(SALDO), Empty(ALTA), Empty(NOMBRE), "|"
   dbCloseArea()
RETURN
