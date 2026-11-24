FUNCTION Work()
 LOCAL a:={"ccc","a","bb",""},i,probe:={2,1}
 ASort(probe)
 ASort(a)
 FOR i:=1 TO 137
  a:={"ccc","a","bb",""}
  a[2]:=Replicate("a",21)
  ASort(a)
 NEXT
RETURN a[4]
FUNCTION Main()
 LOCAL i,c,probe:={2,1}
 ASort(probe)
 FOR i:=1 TO 43
  c:=Work()
 NEXT
 ? c
RETURN NIL
