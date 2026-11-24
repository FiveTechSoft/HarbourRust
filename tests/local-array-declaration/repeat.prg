PROCEDURE Main()
 LOCAL i:=0
 FOR i:=1 TO 71
  ? Build(i)
 NEXT
RETURN
FUNCTION Build(n)
 LOCAL a[n],i:=0
 FOR i:=1 TO Len(a)
  a[i]:=i*3
 NEXT
RETURN Len(a)
