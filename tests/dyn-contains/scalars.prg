PROCEDURE Main()
 LOCAL s:=NIL,i:=0,n:=0,e:=NIL,l:=.F.
 FOR i:=1 TO 137
  s:=1.5
  BEGIN SEQUENCE WITH {|z|Break(z)}
   l:="x" $ s
  RECOVER USING e
   n++
  END SEQUENCE
  s:="prefix Lu suffix"
  l:="Lu" $ s
  IF l .AND. !("LL" $ s)
   n++
  ENDIF
 NEXT
 ? n,l,s
RETURN
