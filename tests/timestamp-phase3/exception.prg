FUNCTION FailText()
 Break("stop")
RETURN "x"
FUNCTION TextValue(a,fail)
 LOCAL s:=hb_TToC(a[1],"YYYY-MM-DD","HH:MM:SS.fff")
 IF fail
  s+=FailText()
 ENDIF
RETURN s
FUNCTION Work()
 LOCAL a,i,e,n:=0
 FOR i:=1 TO 101
  a:={}
  AAdd(a,hb_SToT("20261123101530987"))
  AAdd(a,"suffix")
  BEGIN SEQUENCE
   TextValue(a,.T.)
  RECOVER USING e
   n++
  END SEQUENCE
 NEXT
 ? n,TextValue(a,.F.),a[2]
RETURN NIL
FUNCTION Main()
 Work()
RETURN NIL
