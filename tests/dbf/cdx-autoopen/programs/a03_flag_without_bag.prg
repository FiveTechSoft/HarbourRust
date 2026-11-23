function main()
 dbUseArea(.T., "DBFCDX", "auto_m.dbf", "W", .F., .T.)
 ? RecNo(), W->CCOD
 dbSetOrder(1)
 dbGoTop()
 ? RecNo(), W->CCOD
 dbCloseArea()
return nil
