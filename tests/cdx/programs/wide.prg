request DBFCDX
function Main()
   local i := 0
   dbUseArea(.T.,"DBFCDX","wide.dbf","W",.F.,.T.)
   OrdListAdd("widekeys.cdx")
   for i := 1 to 252
      ? "wide", RecNo(), Bof(), Eof()
      OutStd(FieldGet(1),hb_eol())
      dbSkip()
   next
   ? dbSeek("K00"), RecNo(), Found()
   ? dbSeek("K00",.F.,.T.), RecNo(), Found()
   ? dbSeek("K000X",.T.,.T.), RecNo(), Found()
   dbGoBottom()
   for i := 1 to 252
      ? "back", RecNo(), Bof(), Eof()
      OutStd(FieldGet(1),hb_eol())
      dbSkip(-1)
   next
   dbCloseArea()
return nil
