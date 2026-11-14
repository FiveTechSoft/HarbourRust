function Main()
local a,b,n,m
 dbUseArea(.T.,"DBFNTX","fixture.dbf","T",.F.,.T.)
 a:=FieldGet(5)
 b:=FieldGet(5)
 n:=FieldGet(2)
 m:=FieldGet(2)
 ? a==b,a=b,a<b,a>b,a<=b,a>=b
 ? n==m,n=m,n<m,n>m,n<=m,n>=m,n==42,n=42,n<43,n>41
 dbSkip(1)
 b:=FieldGet(5)
 ? a==b,a=b,a<b,a>b,a<=b,a>=b
 dbCloseArea()
 ? a,b
 return nil
