request DBFCDX
function Main()
   local i := 0, total := 0
   dbUseArea(.T.,"DBFCDX","deep.dbf","DEEPTEST",.F.,.T.)
   OrdListAdd("deepkeys.cdx")
   for i := 1 to 20000
      total += RecNo()
      dbSkip()
   next
   ? "sum",total,RecNo(),Bof(),Eof()
   ? dbSeek("K0000"),RecNo(),FieldGet(1),Found()
   ? dbSeek("K0000",.F.,.T.),RecNo(),FieldGet(1),Found()
   ? dbSeek("K0996"),RecNo(),FieldGet(1),Found()
   ? dbSeek("K0996",.F.,.T.),RecNo(),FieldGet(1),Found()
   dbCloseArea()
return nil
