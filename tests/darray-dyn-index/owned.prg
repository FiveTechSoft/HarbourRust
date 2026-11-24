PROCEDURE Main()
 LOCAL a:=Array(2),i:=NIL,j:=0,e:=NIL,n:=0,x:=NIL
 FOR j:=1 TO 137
  x:=Replicate("abc",7)
  i:=1
  a[i]:=x
  i:=2
  a[i]:=x
  BEGIN SEQUENCE WITH {|z|Break(z)}
   i:=0
   a[i]:=x
  RECOVER USING e
   n++
  END SEQUENCE
  BEGIN SEQUENCE WITH {|z|Break(z)}
   i:=NIL
   a[i]:=x
  RECOVER USING e
   n++
  END SEQUENCE
 NEXT
 ? n,a[1],a[2],x
RETURN
