/* Harbour-only holder: keeps shr.dbf open (S shared, X exclusive) and
 * read-write; on append.flag appends one record and signals appended.flag;
 * closes on stop.flag. */
REQUEST DBFCDX
procedure Main(cMode)
 local n := 0
 rddSetDefault("DBFCDX")
 dbUseArea(.T., "DBFCDX", "shr.dbf", "HO", cMode == "S", .F.)
 if NetErr()
   ? "holder neterr"
   return
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
