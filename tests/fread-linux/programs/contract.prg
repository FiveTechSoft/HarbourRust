FUNCTION Main()
 LOCAL h:=FCreate("data"),s:="12345",n
 FWrite(h,"ab"+Chr(0)+"cdXY")
 FClose(h)
 h:=FOpen("data")
 n:=FRead(h,@s,3)
 ? n,Len(s),Asc(SubStr(s,3,1)),">"+Left(s,2)+"<",">"+Right(s,2)+"<"
 ? FRead(h,@s,9),Len(s),">"+s+"<"
 ? FRead(h,@s,2),Len(s),">"+s+"<"
 ? FRead(-1,@s,2),Len(s),">"+s+"<"
 FClose(h)
RETURN NIL
