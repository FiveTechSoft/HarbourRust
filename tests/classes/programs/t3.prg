#include "hbclass.ch"
CREATE CLASS TTipos
   DATA i INIT 5
   DATA s INIT "hey"
   DATA l INIT .T.
   DATA f INIT 2.5
   DATA z
ENDCLASS
PROCEDURE Main()
   LOCAL o
   o := TTipos()
   ? o:i, o:s, o:l, o:f
   ? o:z
   o:l := .F.
   ? o:l
RETURN
