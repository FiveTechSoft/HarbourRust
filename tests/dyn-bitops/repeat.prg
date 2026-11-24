PROCEDURE Main()
 LOCAL a:=NIL,b:=NIL,i:=0,n:=0,e:=NIL
 FOR i:=1 TO 157
  a:=1.9
  b:=-1.9
  ? hb_bitOr(a,2,4),hb_bitAnd(b,127,31),hb_bitXor(a,b,9),hb_bitNot(b)
  a:="abc"+Str(i)
  BEGIN SEQUENCE WITH {|z|Break(z)}
   n:=hb_bitOr(1,a,2)
  RECOVER USING e
   n++
  END SEQUENCE
 NEXT
 ? n,a
RETURN
