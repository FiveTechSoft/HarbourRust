STATIC n:=0
FUNCTION Ix(i)
 n:=n*10+i
RETURN i
FUNCTION Main()
 LOCAL a:={{NIL}},b:={{"text",{NIL,.T.,19.25,SToD("20040229"),{"deep",17,NIL,.F.}}}},c
 a[1,1]:=1
 ? HB_ISARRAY(b[1,1]),HB_ISARRAY(b[1,2]),HB_ISNUMERIC(b[1,2])
 ? HB_ISNUMERIC(b[1,2,1]),HB_ISNUMERIC(b[1][2,2]),HB_ISNUMERIC(b[1,2,3]),HB_ISNUMERIC(b[1,2,4]),HB_ISARRAY(b[1,2,5])
 ? HB_ISARRAY(b[1,2,5,1]),HB_ISNUMERIC(b[1][2,5][2]),HB_ISNUMERIC(b[1,2,5,3]),HB_ISNUMERIC(b[1,2,5,4])
 ? HB_ISNUMERIC(b[Ix(1)][Ix(2),Ix(5)][Ix(2)]),n
 c:=b
 c[1,2,5,2]:="changed"
 ? HB_ISNUMERIC(b[1,2,5,2])
RETURN NIL
