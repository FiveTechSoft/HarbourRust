FUNCTION Main()
LOCAL a:="A",b:="",n:=0,i:=0,v:={1,2},bad:=0
? IsAlpha(IIf(.T.,a+"x",b+"")),IsUpper(IIf(.F.,a+"",b+"z"))
? IsLower(IIf(.F.,a+"",b+"z")),IsDigit(IIf(.T.,b+"9",a+""))
? IsAlpha(IIf(++n==1,IIf(++n==2,a+"x",b+""),IIf(++n==99,b+"",a+""))),n
? IsAlpha(IIf(.T.,a+"",IIf(v[bad]==0,a+"",b+""))),n
? IsAlpha(IIf(.T.,b+Chr(0),a+"")),IsDigit(IIf(.F.,a+"",b+b))
FOR i:=1 TO 3
 ? IsUpper(IIf(i==2,IIf(++n>0,a+"x",b+""),IIf(++n>0,b+"z",a+""))),n
NEXT
IF IsDigit(IIf(n>0,b+"9",b+b))
 n++
ENDIF
? n,IIf(IsLower(IIf(.T.,b+"z",a+"")),17,99)
RETURN NIL
