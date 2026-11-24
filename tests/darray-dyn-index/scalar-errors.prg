PROCEDURE Main()
 LOCAL a:=Array(2),i:=NIL,j:=0,e:=NIL,n:=0
 FOR j:=1 TO 131
  BEGIN SEQUENCE WITH {|z|Break(z)}
   i:="1"
   a[i]:=7
  RECOVER USING e
   n++
  END SEQUENCE
  BEGIN SEQUENCE WITH {|z|Break(z)}
   i:=1.5
   a[i]:=8
  RECOVER USING e
   n++
  END SEQUENCE
  BEGIN SEQUENCE WITH {|z|Break(z)}
   i:=.T.
   a[i]:=9
  RECOVER USING e
   n++
  END SEQUENCE
 NEXT
 ? n,a[1],a[2]
RETURN
