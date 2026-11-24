PROCEDURE Main()
 LOCAL a:=NIL,b:=NIL
 a:=9223372036854775807
 b:=-9223372036854775808
 ? hb_bitOr(a,b),hb_bitAnd(a,b),hb_bitXor(a,b),hb_bitNot(a),hb_bitNot(b)
 a:=0
 ? hb_bitNot(a),hb_bitAnd(a,b)
RETURN
