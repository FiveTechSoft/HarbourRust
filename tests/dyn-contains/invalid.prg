PROCEDURE Main()
 LOCAL s:=NIL,i:=0,n:=0,e:=NIL,a:=Array(3)
 a[2]:=7
 a[3]:=.T.
 FOR i:=1 TO 127
  FOR EACH s IN a
   BEGIN SEQUENCE WITH {|z|Break(z)}
    ? "Lu" $ s
   RECOVER USING e
    n++
   END SEQUENCE
  NEXT
 NEXT
 ? n
RETURN
