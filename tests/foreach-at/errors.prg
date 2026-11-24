PROCEDURE Main()
 LOCAL x:=NIL,a:=Array(3),n:=0,i:=0,e:=NIL
 a[2]:=17
 a[3]:=.T.
 FOR i:=1 TO 73
  FOR EACH x IN a
   BEGIN SEQUENCE WITH {|b|Break(b)}
    n:=hb_At("x",x)
   RECOVER USING e
    n++
   END SEQUENCE
  NEXT
 NEXT
 ? n
RETURN
