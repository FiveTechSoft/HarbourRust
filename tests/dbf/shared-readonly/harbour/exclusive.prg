/* Harbour-only: exclusive open of shr.dbf. */
REQUEST DBFCDX
procedure Main()
 dbUseArea(.T., "DBFCDX", "shr.dbf", "EX", .F., .T.)
 ? "exclusive neterr", NetErr()
 if !NetErr()
   dbCloseArea()
 endif
return
