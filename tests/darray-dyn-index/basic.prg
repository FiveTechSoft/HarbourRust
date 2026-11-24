PROCEDURE Main()
 LOCAL a:=Array(4),i:=NIL,j:=0,n:=NIL
 FOR j:=1 TO 257
  i:=1
  n:=hb_HexToNum("29")
  a[i]:=n
  i:=2
  a[i]:=j
  i:=4
  a[i]:=.T.
 NEXT
 ? a[1],a[2],a[3],a[4]
RETURN
