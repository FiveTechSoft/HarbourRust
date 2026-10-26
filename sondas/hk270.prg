PROCEDURE Main()
   P( .F. )
   P( .T. )
   RETURN
FUNCTION P( x )
   ? x
   DO WHILE x
      ? "in"
      EXIT
   ENDDO
   ? "after"
   RETURN
