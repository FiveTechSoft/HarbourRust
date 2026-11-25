FUNCTION Main()
LOCAL a:="ab",b:="",n:=0,i:=0,v:={1,2},bad:=0
? Len(IIf(.T.,a+"x",b+"")),Len(IIf(.F.,a+"",b+Chr(0)+"é"))
? Len(IIf(++n==1,IIf(++n==2,a+"x",b+""),IIf(++n==99,b+"",a+""))),n
? Len(IIf(.T.,a+"",IIf(v[bad]==0,a+"",b+""))),n
FOR i:=1 TO 3
 ? Len(IIf(i==2,IIf(++n>0,a+"x",b+""),IIf(++n>0,b+"",a+""))),n
NEXT
RETURN NIL
