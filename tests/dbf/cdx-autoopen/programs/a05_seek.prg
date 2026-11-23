function main()
 dbUseArea(.T., "DBFCDX", "auto_s.dbf", "S", .F., .T.)
 dbSetOrder(1)
 dbSeek("C002")
 ? Found(), RecNo()
 dbSeek("C009")
 ? Found(), RecNo(), Eof()
 dbCloseArea()
return nil
