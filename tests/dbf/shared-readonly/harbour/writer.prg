/* Harbour-only: shared read-write open of shr.dbf, append one record. */
REQUEST DBFCDX
procedure Main()
 dbUseArea(.T., "DBFCDX", "shr.dbf", "WR", .T., .F.)
 ? "shared rw neterr", NetErr()
 if !NetErr()
   dbAppend()
   WR->CCOD := "C000"; WR->NINT := 9
   dbCommit(); dbUnlock()
   ? LastRec()
   dbCloseArea()
 endif
return
