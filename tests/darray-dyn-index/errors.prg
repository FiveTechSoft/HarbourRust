PROCEDURE Main()
 LOCAL a:=Array(2),indices:=Array(7),i:=NIL,j:=0,e:=NIL,n:=0,x:=NIL
 indices[2]:=.T.
 indices[3]:=0
 indices[4]:=3
 indices[5]:=-1
 indices[6]:=1
 indices[7]:=2
 FOR j:=1 TO 139
  FOR EACH i IN indices
   BEGIN SEQUENCE WITH {|b|Break(b)}
    a[i]:=17
   RECOVER USING e
    n++
   END SEQUENCE
  NEXT
 NEXT
 ? n,a[1],a[2]
RETURN
