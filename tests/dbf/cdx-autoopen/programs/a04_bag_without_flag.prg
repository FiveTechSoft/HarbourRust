function main()
 dbUseArea(.T., "DBFCDX", "auto_n.dbf", "N", .F., .T.)
 ? RecNo(), N->CCOD
 dbSetOrder(1)
 dbGoTop()
 ? RecNo(), N->CCOD
 dbCloseArea()
return nil
