PROCEDURE Main()
LOCAL n:=hb_MilliSeconds(),a
? ValType(n),n,n==Int(n)
a:=hb_MilliSeconds()
? a,a-n,a>=n
RETURN
