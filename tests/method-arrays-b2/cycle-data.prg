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
 LOCAL a:={},b:=a,s:=Store():New(a),f:=Producer():New()
 AAdd(a,a)
 a:={}
 ? s:Size(),Len(b),Len(b[1])
 s:items:=f:Make(.F.)
 b:={}
 ? s:Size()
RETURN NIL
