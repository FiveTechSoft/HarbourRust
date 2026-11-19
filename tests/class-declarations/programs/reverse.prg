#include "hbclass.ch"
CREATE CLASS Child FROM Middle
 VAR left, right
 METHOD Value() INLINE 30
ENDCLASS
CREATE CLASS Middle FROM Root
 DATA middle INIT 20
 METHOD Value() INLINE 20
ENDCLASS
CREATE CLASS Root
 VAR root
 METHOD Value() INLINE 10
 METHOD Through() INLINE ::Value()
ENDCLASS
FUNCTION Main()
 LOCAL o := Child()
 o:left := 1
 o:right := 2
 o:root := 3
 ? o:left, o:right, o:root, o:middle
 ? o:Value(), o:Through()
RETURN NIL
