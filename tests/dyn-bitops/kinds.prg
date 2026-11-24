PROCEDURE Main()
 LOCAL x:=NIL,e:=NIL
 x:=1.9
 ? hb_bitOr(x,2),hb_bitAnd(x,7),hb_bitXor(x,3),hb_bitNot(x)
 x:=-1.9
 ? hb_bitOr(x,2),hb_bitAnd(x,7),hb_bitXor(x,3),hb_bitNot(x)
 x:=NIL
 BEGIN SEQUENCE WITH {|z|Break(z)}
  ? hb_bitOr(x,2)
 RECOVER USING e
  ? "nil caught"
 END SEQUENCE
 x:=.T.
 BEGIN SEQUENCE WITH {|z|Break(z)}
  ? hb_bitOr(x,2)
 RECOVER USING e
  ? "logical caught"
 END SEQUENCE
RETURN
