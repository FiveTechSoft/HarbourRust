#include "hbclass.ch"
FUNCTION Marca( n )
   ?? "I" + LTrim( Str( n ) ) + " "
RETURN n * 10
CREATE CLASS TBase
   DATA b INIT Marca( 1 )
ENDCLASS
CREATE CLASS THija INHERIT TBase
   DATA h INIT Marca( 2 )
ENDCLASS
PROCEDURE Main()
   LOCAL o, p
   ?? "antes|"
   o := THija()
   ?? "creada|"
   ? o:b
   ? o:h
   o:b := 111
   ? o:b
   p := THija()
   ? p:b
RETURN
