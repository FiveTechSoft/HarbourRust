FUNCTION Main()
 LOCAL h:=FCreate("probe.dat"),s
 ? "create",h
 ? "write",FWrite(h,"abc"+Chr(0)+"def")
 ? "close",FClose(h),FClose(h)
 h:=FOpen("probe.dat")
 ? "open",h
 s:=FReadStr(h,7)
 ? "read",Len(s),">"+s+"<"
 ? "eof",Len(FReadStr(h,7))
 ? "close",FClose(h)
 ? "missing",FOpen("does-not-exist")
 ? "error",FWrite(-1,"a"),FClose(-1),Len(FReadStr(-1,7))
RETURN NIL
