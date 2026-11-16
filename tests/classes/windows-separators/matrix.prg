#include "hbclass.ch"
CREATE CLASS T
   DATA a INIT 1
ENDCLASS
PROCEDURE Main()
   LOCAL o
   o := T()
   ? "01", o, "y"
   ? "02", o
   ? "03  ", o
   ? "04", o, o
   ? "05", o, o, "y"
   ? o, "06"
   ? "07", o
   ?? "z"
   ? "08", o
   OutStd("z")
   ? "09", o
   ? "10"
   ? "11", dynobj(o)
   ? "12  ", dynobj(o)
   ? "13", dynobj(o), "y"
   o := NIL
   ? "14", o
   ? "15", o, "y"
   ? "16", T()
RETURN
FUNCTION dynobj(o)
   LOCAL a := o:a
RETURN o
