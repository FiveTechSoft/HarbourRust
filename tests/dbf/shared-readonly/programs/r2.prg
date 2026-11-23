function main()
 dbUseArea(.T., "DBFCDX", "shc.dbf", "S", .T., .T.)
 ? RecNo(), S->CCOD
 dbSetOrder(1)
 dbGoTop()
 ? RecNo(), S->CCOD
 dbCloseArea()
return nil
