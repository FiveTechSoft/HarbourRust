function main()
 dbUseArea(.T., "DBFCDX", "wide2046.dbf", "W", .F., .T.)
 ? FCount(), LastRec()
 dbGoto(3)
 ? FieldGet(1), FieldGet(129), FieldGet(1000), FieldGet(2045), FieldGet(2046)
 ? W->F2046, W->F1
 dbGoTop()
 ? RecNo(), W->F2046
 dbCloseArea()
return nil
