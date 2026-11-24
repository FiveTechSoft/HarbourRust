PROCEDURE Main()
 LOCAL i:=0,n:=0
 FOR i:=1 TO 71
  LOCAL a[2,3],b[0]
  a[1,2]:=i
  n+=a[1,2]+Len(b)
 NEXT
 ? n
RETURN
