function Main()
local i
 dbUseArea(.T.,"DBFNTX","empty.dbf","EMPTY",.F.,.T.)
 ? RecNo(),LastRec(),Bof(),Eof()
 for i:=1 to 3
 ? FieldGet(1),FieldGet(2),FieldGet(3),FieldGet(4),FieldGet(5)
 ? Empty(FieldGet(1)),Empty(FieldGet(2)),Empty(FieldGet(3)),Empty(FieldGet(4)),Empty(FieldGet(5))
 dbSkip()
 ? RecNo(),Bof(),Eof()
 next
 dbSkip(-1)
 ? RecNo(),Bof(),Eof()
 dbGoTop()
 ? RecNo(),Bof(),Eof()
 dbCloseArea()
return nil
