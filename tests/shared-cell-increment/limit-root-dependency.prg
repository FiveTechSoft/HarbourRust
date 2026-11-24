FUNCTION Main()
 LOCAL a:={{1,"keep"}}
 a[1,2]:="safe"
 ? a[1,a[1,1]]++
RETURN NIL
