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
FUNCTION Build(f)
 LOCAL a:=f:Make(.F.),b:=a,c:={},s:=Store():New(c)
 AAdd(c,a)
 AAdd(a,c)
RETURN s
FUNCTION Main()
 LOCAL f:=Producer():New(),s:=Build(f),a:=s:Values(),i,junk:={}
 FOR i:=1 TO 517
  junk:={}
  AAdd(junk,"discard")
 NEXT
 ? Len(a),Len(a[1]),s:Size()
 s:items:=junk
 a:={}
 ? s:Size()
RETURN NIL
