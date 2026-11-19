#include "hbclass.ch"
CREATE CLASS A
 DATA n INIT 5
 METHOD Add(x,y) INLINE ::n+x+y
 METHOD Touch(x)
ENDCLASS
METHOD Touch(x) CLASS A
 ::n := x+0
RETURN 0
CREATE CLASS B FROM A
 METHOD Add(x,y) INLINE 99+x*0+y*0
 METHOD BaseAdd(x,y) INLINE ::super:Add(x+0,y+0)
 METHOD BaseTouch(x) INLINE ::super:Touch(x+0)
 METHOD Nested(x,y) INLINE ::super:Add(Mark(x+0),Mark(y+0))
 METHOD Twice(x) INLINE ::BaseAdd(x+0,x+0)
ENDCLASS
FUNCTION Mark(n)
 ? "arg", n
RETURN n
FUNCTION Main()
 LOCAL o := B()
 ? "add", o:BaseAdd(Mark(1),Mark(2))
 o:BaseTouch(8)
 ? "stored", o:n, o:Twice(3)
 ? "virtual", o:Add(1,2)
 ? "nested", o:BaseAdd(o:Add(1,2),3), o:Nested(4,5)
RETURN NIL
