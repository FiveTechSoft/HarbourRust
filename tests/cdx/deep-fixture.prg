request DBFCDX
function Main()
   local i
   dbCreate("deep", {{"NAME", "C", 12, 0}, {"ID", "N", 6, 0}}, "DBFCDX")
   dbUseArea(.T., "DBFCDX", "deep.dbf", "PROBE", .F., .F.)
   for i := 1 to 20000
      dbAppend()
      FieldPut(1, "K" + StrZero((i * 37) % 997, 4))
      FieldPut(2, i)
   next
   ordCreate("deepkeys.cdx", "NAMES", "NAME", {|| FieldGet(1)})
   ? "count", LastRec(), RecNo(), Bof(), Eof()
   dbGoTop()
   for i := 1 to 6
      ? "top", RecNo(), FieldGet(1), Found(), Bof(), Eof()
      dbSkip()
   next
   dbCloseArea()
return nil
