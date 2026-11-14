request DBFCDX
function Main()
   local i := 0
   dbUseArea(.T.,"DBFCDX","cdxprobe.dbf","P",.F.,.T.)
   OrdListAdd("names.cdx")
   for i := 1 to 253
      ? "forward", RecNo(), FieldGet(1), Deleted(), Bof(), Eof(), Found()
      dbSkip()
   next
   for i := 1 to 253
      dbSkip(-1)
      ? "backward", RecNo(), FieldGet(1), Deleted(), Bof(), Eof(), Found()
   next
   dbCloseArea()
return nil
