// Own MIT: shared arrays reject all ordering operators.
FUNCTION Check(a,b)
 LOCAL e,n:=0
 BEGIN SEQUENCE
  ? a<b
 RECOVER USING e
  ? e
  n++
 END SEQUENCE
 BEGIN SEQUENCE
  ? a<=b
 RECOVER USING e
  ? e
  n++
 END SEQUENCE
 BEGIN SEQUENCE
  ? a>b
 RECOVER USING e
  ? e
  n++
 END SEQUENCE
 BEGIN SEQUENCE
  ? a>=b
 RECOVER USING e
  ? e
  n++
 END SEQUENCE
RETURN n
FUNCTION Main()
 LOCAL a:=AClone({17}),b:=AClone({17}),box:=AClone({{19}}),n:=0,i
 FOR i:=1 TO 7
  n+=Check(a,a)
  n+=Check(a,b)
  n+=Check(a,NIL)
  n+=Check(NIL,a)
  n+=Check(a,17)
  n+=Check(17,a)
  n+=Check(a,19.25)
  n+=Check(19.25,a)
  n+=Check(a,.T.)
  n+=Check(.F.,a)
  n+=Check(box[1],a)
 NEXT
 ? n
RETURN NIL
