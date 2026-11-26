#include "hbclass.ch"
CLASS Counter
METHOD Run()
ENDCLASS
METHOD Run() CLASS Counter
STATIC n:=1.2500
n+=1.5
RETURN n
PROCEDURE Main()
LOCAL o:=Counter():New()
? o:Run(),o:Run()
RETURN
