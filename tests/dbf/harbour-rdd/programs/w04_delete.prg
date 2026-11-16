PROCEDURE Main()
   dbUseArea(.T.,"DBFCDX","clie.dbf","CLIE",.F.,.F.)
   dbGoTo(3)
   dbDelete()
   ? RecNo(), Deleted(), "|"
   dbGoTo(1)
   ? RecNo(), Deleted(), "|"
   dbGoTo(3)
   dbRecall()
   ? Deleted(), "|"
   dbGoTo(2)
   dbDelete()
   dbCloseArea()
RETURN
