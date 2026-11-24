// Own MIT: repeated direct literal returns with caller graph mutation.
FUNCTION Make()
RETURN AClone({"word",19.25,{"child"}})
FUNCTION Work()
 LOCAL a,b,i,n:=0
 FOR i:=1 TO 117
  a:=Make()
  b:=Make()
  a[3]:=a
  b[1]:="changed"
  b[2]:=21.5
  b[3,1]:="leaf"
  n+=Len(a)+Len(b)
 NEXT
RETURN n
FUNCTION Main()
 LOCAL i,n:=0
 FOR i:=1 TO 37
  n+=Work()
 NEXT
 ? n
RETURN NIL
