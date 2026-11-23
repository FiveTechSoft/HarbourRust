function main()
 local r
 dbUseArea(.T., "DBFCDX", "wide187.dbf", "W", .F., .T.)
 ? FCount(), LastRec()
 for r := 1 to 5
  dbGoto(r)
  ? FieldGet(1), FieldGet(2), FieldGet(3), FieldGet(4)
  ? FieldGet(185), FieldGet(186), FieldGet(187)
  ? W->F129, W->F130, W->F131, W->F132
 next
 dbCloseArea()
return nil
