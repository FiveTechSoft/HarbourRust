function Main()
local saved,a,b,c,d,i
 dbUseArea(.T.,"DBFNTX","fixture.dbf","DATA",.F.,.T.)
 saved:=FieldGet(1)
 a:=FieldGet(2)
 b:=FieldGet(3)
 c:=FieldGet(4)
 d:=FieldGet(5)
 for i:=1 to 4
 ? RecNo(),LastRec(),Bof(),Eof(),Deleted()
 ? FieldGet(1),FieldGet(2),FieldGet(3),FieldGet(4),FieldGet(5)
 ? ValType(FieldGet(1)),ValType(FieldGet(2)),ValType(FieldGet(3)),ValType(FieldGet(4)),ValType(FieldGet(5)),ValType(FieldGet(0))
 ? Empty(FieldGet(1)),Empty(FieldGet(2)),Empty(FieldGet(3)),Empty(FieldGet(4)),Empty(FieldGet(5)),Empty(FieldGet(0))
 dbSkip()
 next
 dbSkip(-100)
 ? RecNo(),Bof(),Eof()
 dbGoTop()
 ? RecNo(),Bof(),Eof()
 dbCloseArea()
 ? "retained",saved,a,b,c,d,ValType(d),Empty(d)
 ? "copy",Echo(saved),Echo(a),Echo(b),Echo(c),Echo(d)
 return nil
function Echo(x)
? x
return x
