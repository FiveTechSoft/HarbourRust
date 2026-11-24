// Own MIT: repeated failures before tail selection preserve roots.
FUNCTION Work()
 LOCAL a:=AClone({{{{17}}}}),b,e,n:=0,i
 FOR i:=1 TO 117
  BEGIN SEQUENCE
   b:=ATail(a[0])
  RECOVER USING e
   n++
  END SEQUENCE
  BEGIN SEQUENCE
   b:=ATail(a[2])
  RECOVER USING e
   n++
  END SEQUENCE
  BEGIN SEQUENCE
   b:=ATail(a[1,2])
  RECOVER USING e
   n++
  END SEQUENCE
  BEGIN SEQUENCE
   b:=ATail(a[1,1,2])
  RECOVER USING e
   n++
  END SEQUENCE
  BEGIN SEQUENCE
   b:=ATail(a[1,1,1,2])
  RECOVER USING e
   n++
  END SEQUENCE
  a[1,1,1]:=17
  BEGIN SEQUENCE
   b:=ATail(a[1,1,1,1])
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
