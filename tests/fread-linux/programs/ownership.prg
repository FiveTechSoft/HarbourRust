FUNCTION Work()
 LOCAL h:=FCreate("own.dat"),s:="12345678",i,n:=0
 FWrite(h,"ABCDEFGH")
 FClose(h)
 FOR i:=1 TO 1000
  h:=FOpen("own.dat")
  n:=n+FRead(h,@s,3)+FRead(h,@s,5)+FRead(h,@s,1)
  FClose(h)
 NEXT
 ? n,s,Len(s)
 n:=0
 FOR i:=1 TO 1000
  h:=FOpen("own.dat")
  n:=n+FRead(h,@s,9)
  FClose(h)
 NEXT
 ? n,s,Len(s)
RETURN NIL
FUNCTION Main()
 Work()
RETURN NIL
