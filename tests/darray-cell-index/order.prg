PROCEDURE Main()
 LOCAL src:=Array(1),a:=Array(2),i:=NIL,e:=NIL
 i:=1
 src[1]:=i
   a[src[1]]:=Side(3)
 BEGIN SEQUENCE WITH {|z|Break(z)}
  i:=NIL
  src[1]:=i
   a[src[1]]:=Side(4)
 RECOVER USING e
  ? "caught"
 END SEQUENCE
 ? a[1]
RETURN
FUNCTION Side(n)
 ? "rhs",n
RETURN n
