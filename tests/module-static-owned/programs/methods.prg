#include "hbclass.ch"
STATIC text := "one",flag := .T.
CLASS Holder
METHOD Change()
ENDCLASS
METHOD Change() CLASS Holder
text := "two"
flag := !flag
RETURN text
PROCEDURE Main()
Exercise()
RETURN
FUNCTION Exercise()
LOCAL o := Holder():New()
? o:Change()
? text,flag
RETURN NIL
