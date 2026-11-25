FUNCTION Main()
LOCAL a:="ab",b:="",n:=0
? IIf(.T.,a+"x",b+"y"),IIf(.F.,a+"x",b+"y")
? IIf(++n==1,b+a,a+b),n
?? IIf(++n==2,b+" tail  ",a+b)
OutStd(IIf(n==2,b+"RAW",a+"x"))
? IIf(.T.,b+Chr(0)+"A",a+"z"),IIf(.F.,a+"z",b+"é")
? IIf(.T.,b+b,a+b),IIf(.F.,a+b,b+b),n
RETURN NIL
