PROCEDURE Main()
 LOCAL i:=0,j:=0,n:=0
 FOR j:=1 TO 71
  FOR i:=1 TO 7
   LOCAL a[13]
   a[1]:=i
   n+=a[1]
   IF i==2
    LOOP
   ENDIF
   IF i==5
    EXIT
   ENDIF
  NEXT
 NEXT
 ? n
RETURN
