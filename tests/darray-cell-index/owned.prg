PROCEDURE Main()
 LOCAL src:=Array(1),a:=Array(2),i:=NIL,j:=0,e:=NIL,n:=0,x:=NIL
 FOR j:=1 TO 137
  x:=Replicate("abc",7)
  i:=1
  src[1]:=i
   a[src[1]]:=x
  i:=2
  src[1]:=i
   a[src[1]]:=x
  BEGIN SEQUENCE WITH {|z|Break(z)}
   i:=0
   src[1]:=i
   a[src[1]]:=x
  RECOVER USING e
   n++
  END SEQUENCE
  BEGIN SEQUENCE WITH {|z|Break(z)}
   i:=NIL
   src[1]:=i
   a[src[1]]:=x
  RECOVER USING e
   n++
  END SEQUENCE
 NEXT
 ? n,a[1],a[2],x
RETURN
