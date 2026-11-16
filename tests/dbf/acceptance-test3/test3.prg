PROCEDURE Main()
   ? "Abriendo base de datos M_CLIE.DBF..."
   DBUSEAREA(.T.,"DBFCDX","M_CLIE.DBF","CLIE",.F.,.F.)
   ? CLIENTE
   DBCLOSEAREA()
   ? "Programa finalizado correctamente."
RETURN
