PROCEDURE Main()
 LOCAL a:=Array(2),i:=NIL,e:=NIL
 i:=1
 a[i]:=Side(3)
 BEGIN SEQUENCE WITH {|z|Break(z)}
  i:=NIL
  a[i]:=Side(4)
 RECOVER USING e
  ? "caught"
 END SEQUENCE
 ? a[1]
RETURN
FUNCTION Side(n)
 ? "rhs",n
RETURN n
