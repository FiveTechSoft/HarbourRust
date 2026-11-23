#include "hbclass.ch"
CLASS A
 METHOD Apply(flag,d)
ENDCLASS
METHOD Apply(flag,d) CLASS A
 IF flag
 RETURN d
 ENDIF
RETURN .F.
CLASS B
 METHOD Apply(flag,d)
ENDCLASS
METHOD Apply(flag,d) CLASS B
 IF flag
 RETURN "B"
 ENDIF
RETURN "B"
FUNCTION FetchResult(o,f,d)
 LOCAL v:=o:Apply(f,d)
RETURN ValType(v)
FUNCTION Main()
 LOCAL a:=A():New(),b:=B():New(),d:=CToD("2026/11/23")
 ? FetchResult(a,.T.,d),FetchResult(a,.F.,d),FetchResult(b,.T.,d)
RETURN NIL
