#include "hbclass.ch"
CLASS Entry
 DATA stamp
ENDCLASS
FUNCTION Main()
 LOCAL a:={}
 AAdd(a,1)
 a:={}
 ? Len(a)
RETURN NIL
