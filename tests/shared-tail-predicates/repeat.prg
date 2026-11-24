FUNCTION Work()
 LOCAL a:={{NIL}},b:={},i,n:=0
 a[1,1]:=1
 FOR i:=1 TO 117
  AAdd(b,Replicate("word",31))
  IF HB_ISSTRING(ATail(b)).AND.!HB_ISNUMERIC(ATail(b)).AND.!HB_ISARRAY(ATail(b))
   n++
  ENDIF
  ASize(b,0)
  AAdd(b,19.25)
  IF HB_ISNUMERIC(ATail(b))
   n++
  ENDIF
  ASize(b,0)
 NEXT
RETURN n
FUNCTION Main()
 LOCAL i,n:=0
 FOR i:=1 TO 37
  n+=Work()
 NEXT
 ? n
RETURN NIL
