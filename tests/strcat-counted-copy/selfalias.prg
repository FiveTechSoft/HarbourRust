FUNCTION Main()
LOCAL s:=""+"a"+Chr(0)+"z",i
FOR i:=1 TO 12
 s:=s+s
 ? i,Len(s),Asc(SubStr(s,2,1)),Left(s,3)==Right(s,3)
NEXT
s:=s+s
? Len(s)
RETURN NIL
