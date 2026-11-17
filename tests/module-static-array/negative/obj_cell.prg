#include "hbclass.ch"
STATIC a := {1,2}
CREATE CLASS P
   DATA x INIT 7
ENDCLASS
PROCEDURE Main()
LOCAL o := P()
a[1] := o
RETURN
