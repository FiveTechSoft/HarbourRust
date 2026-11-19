FUNCTION Main()
 LOCAL h:=FCreate("stream.dat"),s
 ? FWrite(h,"abc"+Chr(0)+"def"+"TAIL"),FClose(h)
 h:=FOpen("stream.dat")
 s:=FReadStr(h,7)
 ? ">"+s+"<",">"+FReadStr(h,4)+"<",Len(FReadStr(h,1)),FClose(h)
RETURN NIL
