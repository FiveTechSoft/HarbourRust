FUNCTION Main()
 LOCAL a:={{1,"keep"}}
 a[1,2]:="safe"
 ? a[1.5,1]++
RETURN NIL
