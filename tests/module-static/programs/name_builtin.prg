STATIC month := 3, str := 4
PROCEDURE Main()
? month,str,Str(Month(SToD("20261116")),3)
Bump()
? month,str
RETURN
FUNCTION Bump()
month := month+1
str := str+2
RETURN NIL
