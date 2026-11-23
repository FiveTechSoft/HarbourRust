function main()
 dbUseArea(.T., "DBFCDX", "auto_s.dbf", "S", .F., .T.)
 ? RecNo(), S->CCOD
 dbSkip()
 ? RecNo(), S->CCOD
 dbSetOrder(1)
 ? RecNo(), S->CCOD
 dbGoTop()
 ? RecNo(), S->CCOD
 dbSkip()
 ? RecNo(), S->CCOD
 dbSeek("C003")
 ? Found(), RecNo()
 dbSetOrder(0)
 dbGoTop()
 ? RecNo(), S->CCOD
 dbCloseArea()
return nil
