function main()
 dbUseArea(.T., "DBFCDX", "auto_s.dbf", "S", .F., .T.)
 ordListAdd("auto_s.cdx")
 ? RecNo(), S->CCOD
 dbSkip()
 ? RecNo(), S->CCOD
 dbCloseArea()
return nil
