/* Harbour-only holder of shr.dbf (or the table in cFile), read-write.
 * cMode: S shared, X exclusive, SA shared and appends one committed record
 * before signalling ready, SU shared and appends one record without
 * dbCommit/dbUnlock before signalling ready. On append.flag it appends one
 * record and signals appended.flag; it closes on stop.flag. */
REQUEST DBFCDX
procedure Main(cMode, cFile)
 local n := 0
 rddSetDefault("DBFCDX")
 if Empty(cFile)
   cFile := "shr.dbf"
 endif
 dbUseArea(.T., "DBFCDX", cFile, "HO", !(cMode == "X"), .F.)
 if NetErr()
   ? "holder neterr"
   return
 endif
 if cMode == "SA" .or. cMode == "SU"
   dbAppend()
   HO->CCOD := "C000"; HO->NINT := 9
   if cMode == "SA"
     dbCommit(); dbUnlock()
   endif
 endif
 hb_MemoWrit("ready.flag", "1")
 do while !File("append.flag") .and. !File("stop.flag") .and. n < 600
   hb_idleSleep(0.05); n++
 enddo
 if File("append.flag")
   dbAppend()
   HO->CCOD := "C000"; HO->NINT := 9
   dbCommit(); dbUnlock()
   hb_MemoWrit("appended.flag", "1")
 endif
 do while !File("stop.flag") .and. n < 600
   hb_idleSleep(0.05); n++
 enddo
 dbCloseArea()
return
