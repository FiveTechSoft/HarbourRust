#include "hbclass.ch"
CREATE CLASS T
   DATA a INIT 1
ENDCLASS
PROCEDURE Main()
   LOCAL o := T()
   ? "A", o
   ?? ""
   ? "B", o
   OutErr("!")
   ? "C", o
   ?? "z"
   ? "D", o, "", o
   ? "E", o, "v"
   ? "F", makeobj()
   ? "G", o
   ? "H", makeobj(), "v"
   ? "I", o
   OutStd("")
   ?? "z"
   ? "J", o
RETURN
FUNCTION makeobj()
RETURN T()
