PROCEDURE Main()
 LOCAL a:=NIL,b:=NIL,i:=0,n:=0,e:=NIL
 FOR i:=1 TO 151
  a:="abc"+Str(i)
  b:=7
  BEGIN SEQUENCE WITH {|z|Break(z)}
   n:=hb_bitAnd(a,b)
  RECOVER USING e
   n++
  END SEQUENCE
  BEGIN SEQUENCE WITH {|z|Break(z)}
   n:=hb_bitXor(b,a)
  RECOVER USING e
   n++
  END SEQUENCE
  BEGIN SEQUENCE WITH {|z|Break(z)}
   n:=hb_bitNot(a)
  RECOVER USING e
   n++
  END SEQUENCE
 NEXT
 ? n,a,b
RETURN
