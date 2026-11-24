#include "hbclass.ch"
CLASS Store
 DATA items
 METHOD New(a)
 METHOD Size()
 METHOD Values()
ENDCLASS
METHOD New(a) CLASS Store
 ::items:=a
RETURN Self
METHOD Size() CLASS Store
RETURN Len(::items)
METHOD Values() CLASS Store
RETURN ::items
CLASS Producer
 DATA count INIT 4
 METHOD Make(fail)
 METHOD Wrap(fail)
ENDCLASS
METHOD Make(fail) CLASS Producer
 LOCAL a:={},i
 FOR i:=1 TO ::count
  AAdd(a,"r"+Str(i,1))
  IF fail .AND. i==3
   Break("stop")
  ENDIF
 NEXT
RETURN a
METHOD Wrap(fail) CLASS Producer
RETURN Store():New(::Make(fail))
FUNCTION Main()
 LOCAL f:=Producer():New(),a:={},s:=Store():New(a),b
 AAdd(a,1.25)
 AAdd(a,CToD("2026/11/23"))
 AAdd(a,.T.)
 AAdd(a,iif(.T.,"str",9))
 b:=s:Values()
 ? ValType(b[1]),ValType(b[2]),ValType(b[3]),b[4]
RETURN NIL
