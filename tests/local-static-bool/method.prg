#include "hbclass.ch"
CLASS Counter
METHOD Run()
ENDCLASS
METHOD Run() CLASS Counter
STATIC n:=.T.
n:=!n
RETURN n
PROCEDURE Main()
LOCAL o:=Counter():New()
? o:Run(),o:Run()
RETURN
