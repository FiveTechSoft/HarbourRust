PROCEDURE Main()
   P( .T. )
   P( .F. )
   P( NIL )
   RETURN
FUNCTION P( x )
   ? x
   IF x
      ? "yes"
   ELSE
      ? "no"
   ENDIF
   RETURN
