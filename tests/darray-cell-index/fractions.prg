PROCEDURE Main()
 LOCAL src:=Array(1),a:=Array(3),i:=NIL,j:=0,e:=NIL,n:=0
 FOR j:=1 TO 127
  i:=1.99
  src[1]:=i
   a[src[1]]:=21
  i:=2.01
  src[1]:=i
   a[src[1]]:=22
  i:=3.9
  src[1]:=i
   a[src[1]]:=23
  BEGIN SEQUENCE WITH {|z|Break(z)}
   i:=-0.99
   src[1]:=i
   a[src[1]]:=24
  RECOVER USING e
   n++
  END SEQUENCE
  BEGIN SEQUENCE WITH {|z|Break(z)}
   i:=-1.9
   src[1]:=i
   a[src[1]]:=25
  RECOVER USING e
   n++
  END SEQUENCE
  BEGIN SEQUENCE WITH {|z|Break(z)}
   i:=4.01
   src[1]:=i
   a[src[1]]:=26
  RECOVER USING e
   n++
  END SEQUENCE
  BEGIN SEQUENCE WITH {|z|Break(z)}
   i:=100000000000000000000.5
   src[1]:=i
   a[src[1]]:=27
  RECOVER USING e
   n++
  END SEQUENCE
 NEXT
 ? n,a[1],a[2],a[3]
RETURN
