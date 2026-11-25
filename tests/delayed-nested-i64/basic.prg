PROCEDURE Main()
 LOCAL a,b:=1,i:=0
 a:={{1,2},{3,4,5}}
 ? Len(a),a[1][1],a[2][3]
 a[1][1]:=17
 ? a[1][1]
 FOR i:=1 TO Len(a)
 ? a[i][1]
 NEXT
RETURN
