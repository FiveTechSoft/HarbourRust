PROCEDURE Main()
   dbUseArea(.T.,"DBFCDX","clie.dbf","CLIE",.F.,.F.)
   ordCreate("clie", "MAL", "EDAD+NOMBRE")
   ? "no"
RETURN
