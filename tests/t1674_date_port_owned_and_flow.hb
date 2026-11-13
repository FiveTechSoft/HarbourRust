PROCEDURE Main()
LOCAL s:=" 1/5/1999 ", d:=CToD(s), e:=CToD("")
? d, e
? CToD(AllTrim(s)), CToD(s+""), CToD(Replicate("1",1)+"/5/1999")
? s
? DateResult(), DateResult()=d
? d=d,d==d,d<>e,e<d,e<=e,d>=e,d>e
? Empty(e),Empty(d),ValType(d)
d:=CToD("12/31/2000")
? d
RETURN
FUNCTION DateResult()
RETURN CToD("1/5/1999")
