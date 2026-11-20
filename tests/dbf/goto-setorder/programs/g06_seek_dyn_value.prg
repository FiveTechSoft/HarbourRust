function Main()
local c := ""
dbUseArea(.T.,"DBFNTX","goto_set.dbf","GOTO",.F.,.F.)
ordListAdd("goto_set.ntx")
dbGoTop()
dbSeek(KEY)
? "seek field:", RecNo(), Found(), Eof()
dbSkip()
? "skip:", RecNo(), Found()
dbSeek(KEY)
? "again:", RecNo(), Found()
c := KEY
dbGoto(5)
dbSeek(c)
? "seek dyn local:", RecNo(), Found()
dbSeek("000001")
? "seek literal:", RecNo(), Found()
dbCloseArea()
return nil
