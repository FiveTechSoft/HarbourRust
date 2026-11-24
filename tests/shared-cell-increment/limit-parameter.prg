FUNCTION Inc(a)
RETURN a[1,1]++
FUNCTION Main()
 LOCAL a:={{1,"keep"}}
 a[1,2]:="safe"
 ? Inc(a)
RETURN NIL
