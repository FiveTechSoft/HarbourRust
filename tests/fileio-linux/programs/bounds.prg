FUNCTION Main()
 LOCAL h:=FCreate("bounds.dat"),s:=Replicate("x",4096),r:=""
 ? FWrite(h,s),FClose(h),Len(s)
 h:=FOpen("bounds.dat")
 r:=FReadStr(h,1048576)
 ? Len(r),Left(r,3),Len(FReadStr(h,1048576)),FClose(h)
 ? FCreate(Replicate("a",4097)),FOpen("absent")
RETURN NIL
