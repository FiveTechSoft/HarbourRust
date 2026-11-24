// Own MIT: repeated failures before graph construction preserve roots.
FUNCTION Work()
 LOCAL a:=AClone({{{{17}}}}),b,e,n:=0,i
 FOR i:=1 TO 117
  BEGIN SEQUENCE
   b:=AClone(a[0])
  RECOVER USING e
   n++
  END SEQUENCE
  BEGIN SEQUENCE
   b:=AClone(a[2])
  RECOVER USING e
   n++
  END SEQUENCE
  BEGIN SEQUENCE
   b:=AClone(a[1,2])
  RECOVER USING e
   n++
  END SEQUENCE
  BEGIN SEQUENCE
   b:=AClone(a[1,1,2])
  RECOVER USING e
   n++
  END SEQUENCE
  BEGIN SEQUENCE
   b:=AClone(a[1,1,1,2])
  RECOVER USING e
   n++
  END SEQUENCE
  a[1,1,1]:=17
  BEGIN SEQUENCE
   b:=AClone(a[1,1,1,1])
  RECOVER USING e
   n++
  END SEQUENCE
  a[1,1,1]:={17}
 NEXT
 ? n,a[1,1,1,1]
RETURN NIL
FUNCTION Main()
 Work()
RETURN NIL
