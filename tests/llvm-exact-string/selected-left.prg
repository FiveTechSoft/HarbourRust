FUNCTION Main()
LOCAL n:=0,a:="ab",v:={1},bad:=99,k:=9223372036854775807
? IIf(++n==1,"ab","x")==a,n
? IIf(++n==2,"","x")=="",n
? IIf(.T.,"x","x ")=="x ",IIf(.T.,"x ","x")=="x"
? IIf(.T.,Chr(0),"")==Chr(0),IIf(.T.,"é中","")=="é中"
? !(IIf(.T.,"a","A")=="A"),IIf(.T.,"ab","a")=="a"
? IIf(.T.,"x",IIf(v[bad]==1,"bad","x"))=="x"
? IIf(.F.,IIf(++k>0,"bad",""),"x")=="x",k
? IIf(++n==3,IIf(++n==4,"x",""),"bad")=="x",n
IF IIf(.T.,"x","")=="x"
 n++
ENDIF
? n,Empty(IIf(.T.,"","x")=="")
RETURN NIL
