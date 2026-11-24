FUNCTION Main()
 LOCAL a:={{NIL}},b,c
 a[1,1]:=1
 b:=Array(0)
 ? ATail(b)
 AAdd(b,17)
 ? ATail(b),SharedLast(b)
 AAdd(b,"word")
 c:=ATail(b)
 b[2]:="changed"
 ? c,ATail(b)
 AAdd(b,19.25)
 c:=ATail(b)
 b[3]:=21.5
 ? c,ATail(b)
 AAdd(b,{"nested"})
 c:=ATail(b)
 c[1]:="alias"
 ? b[4,1]
RETURN NIL

FUNCTION SharedLast(a)
RETURN ATail(a)
