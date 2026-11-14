#include "hbclass.ch"
CREATE CLASS TPadre
   DATA n INIT 1
ENDCLASS
CREATE CLASS THijo INHERIT TPadre
   DATA m INIT 2
ENDCLASS
PROCEDURE Main()
   LOCAL b
   b := TPadre()
   b := THijo()
   ? b:n
RETURN
