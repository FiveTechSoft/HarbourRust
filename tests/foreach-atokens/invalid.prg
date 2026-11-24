PROCEDURE Main()
 LOCAL x:=NIL,a:=Array(3),i:=0,e:=NIL,n:=0
 LOCAL b:=hb_ATokens("seed",";")
 a[2]:=17
 a[3]:=.T.
 FOR i:=1 TO 73
  FOR EACH x IN a
   BEGIN SEQUENCE WITH {|b|Break(b)}
    b:=hb_ATokens(x,";")
   RECOVER USING e
    n++
   END SEQUENCE
  NEXT
 NEXT
 ? n,Len(b),b[1]
RETURN
