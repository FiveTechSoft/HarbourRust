function Main()
 dbUseArea(.T.,"DBFNTX","fixture.dbf","DATA",.F.,.T.)
 dbSkip()
 ? "blank",FieldGet(5)
 ? "blank",FieldGet(5),"x"
 OutStd("raw[",FieldGet(5),"]",Chr(10))
 OutErr("err[",FieldGet(5),"]",Chr(10))
 OutErr("nums[",FieldGet(2),FieldGet(3),"]",Chr(10))
 dbCloseArea()
return nil
