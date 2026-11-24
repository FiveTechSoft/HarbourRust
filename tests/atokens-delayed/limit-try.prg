PROCEDURE Main()
 LOCAL a:=NIL,x:="a;b",e:=NIL
 BEGIN SEQUENCE WITH {|z|Break(z)}
  a:=hb_ATokens(x,";")
 RECOVER USING e
  ? ValType(a)
 END SEQUENCE
RETURN
