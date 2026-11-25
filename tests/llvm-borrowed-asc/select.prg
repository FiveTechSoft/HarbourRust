FUNCTION Main()
LOCAL a:="A",b:="",n:=0,i:=0,v:={1,2},bad:=0
? Asc(IIf(.T.,a+"x",b+"")),Asc(IIf(.F.,a+"",b+Chr(0)))
? Asc(IIf(.F.,a+"",b+"é")),Asc(IIf(.T.,b+b,a+""))
? Asc(IIf(++n==1,IIf(++n==2,a+"x",b+""),IIf(++n==99,b+"",a+""))),n
? Asc(IIf(.T.,a+"",IIf(v[bad]==0,a+"",b+""))),n
FOR i:=1 TO 3
 ? Asc(IIf(i==2,IIf(++n>0,a+"x",b+""),IIf(++n>0,b+Chr(127),a+""))),n
NEXT
RETURN NIL
