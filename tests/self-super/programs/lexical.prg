#include "hbclass.ch"
CREATE CLASS A
 METHOD Which() INLINE 1
 METHOD Virtual() INLINE ::Which()
ENDCLASS
CREATE CLASS B FROM A
 METHOD Which() INLINE 2
 METHOD Parent() INLINE ::super:Which()
 METHOD ParentVirtual() INLINE ::super:Virtual()
ENDCLASS
CREATE CLASS C FROM B
 METHOD Which() INLINE 3
 METHOD GrandParent() INLINE ::super:Parent()
ENDCLASS
FUNCTION Main()
 LOCAL o := C()
 ? o:Which(), o:Parent(), o:GrandParent(), o:ParentVirtual()
RETURN NIL
