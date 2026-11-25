FUNCTION Main()
LOCAL a:={1},bad:=99,n:=0,k:=9223372036854775807
? "x"==IIf(.T.,"x",IIf(a[bad]==1,"bad","x"))
? "x"==IIf(.F.,IIf(++k>0,"bad",""),"x"),k
? "x"==IIf(++n==1,IIf(++n==2,"x",""),"bad"),n
IF "x"==IIf(.T.,"x","")
 n++
ENDIF
? n,Empty(""==IIf(.T.,"","x"))
RETURN NIL
