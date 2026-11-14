#include "hbclass.ch"
CREATE CLASS TPunto
   DATA x INIT 10
   DATA y INIT 20
   DATA s INIT "AB"
ENDCLASS
PROCEDURE Main()
   LOCAL o
   o := TPunto()
   ? o
   ? o:x
   ? o:y
   ? o:s
   o:x := 7
   ? o:x
   o:s := "nuevo valor"
   ? o:s
   o:s := "otro mas largo que el anterior"
   ? o:s
   o := NIL
   ? o
RETURN
