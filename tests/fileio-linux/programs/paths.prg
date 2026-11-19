FUNCTION Main()
 LOCAL h, s := "probe"+Chr(0)+"ignored"
 h:=FCreate(s)
 ? h>=0, FWrite(h,"new"), FClose(h)
 h:=FOpen("probe")
 ? FReadStr(h,9), FWrite(h,"x"), FClose(h)
 h:=FCreate("probe")
 ? FClose(h)
 h:=FOpen("probe")
 ? Len(FReadStr(h,1)), FClose(h)
 ? FCreate(""), FOpen(""), FCreate("absent/child"), FOpen(".")>=0
 h:=FOpen("limité.dat")
 ? FReadStr(h,20), FClose(h)
RETURN NIL
