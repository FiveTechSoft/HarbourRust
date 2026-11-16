PROCEDURE Main()
   dbUseArea(.T.,"DBFCDX","clie.dbf","CLIE",.F.,.T.)
   ? LastRec()
   dbAppend()
   ? "no"
RETURN
