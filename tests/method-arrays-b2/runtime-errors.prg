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
CLASS Mixed
 METHOD Result(n)
ENDCLASS
METHOD Result(n) CLASS Mixed
 IF n==1
 RETURN Self
 ENDIF
 IF n==2
 RETURN 1.25
 ENDIF
RETURN "not integer"
FUNCTION Main()
 LOCAL f:=Producer():New(),s:=f:Wrap(.F.),m:=Mixed():New(),a:=s:Values(),i,j:=0,e,k:=0
 FOR i:=1 TO 101
  BEGIN SEQUENCE
   s:items:=m:Result(1)
  RECOVER USING e
   k++
  END SEQUENCE
  BEGIN SEQUENCE
   AAdd(a,m:Result(1))
  RECOVER USING e
   k++
  END SEQUENCE
  BEGIN SEQUENCE
   j:=Len(m:Result(1))
  RECOVER USING e
   k++
  END SEQUENCE
  BEGIN SEQUENCE
   FOR j:=1 TO m:Result(2)
   NEXT
  RECOVER USING e
   k++
  END SEQUENCE
 NEXT
 ? k,s:Size()
RETURN NIL
