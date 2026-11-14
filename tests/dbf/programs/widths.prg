function Main()
local a,b
? "OPEN",ValType(dbUseArea(.T.,"DBFNTX","widths.dbf","W",.F.,.T.))
a:=FieldGet(1)
b:=FieldGet(2)
? a,b,a==b,a=b,a<=b,a>=b,a<b,a>b
? "INTEGER",a+1,b-2,HB_NToS(a)
? "DECRET",ValType(dbSkip(0)),ValType(dbGoTop()),ValType(dbCloseArea())
return nil
