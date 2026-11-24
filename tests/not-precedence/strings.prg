PROCEDURE Main()
 LOCAL s:="alpha",x:=NIL,j:=0,n:=0
 FOR j:=1 TO 101
  IF !x==NIL .OR. !s="al"
   n++
  ENDIF
  ? .NOT. "ph" $ s,!s=="alpha",!(s=="beta"),!1.25<2
 NEXT
 ? n
RETURN
