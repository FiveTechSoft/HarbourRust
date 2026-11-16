#include "hbclass.ch"
STATIC text := "old"
CLASS Holder
METHOD Change()
ENDCLASS
METHOD Change() CLASS Holder
text := "new"
RETURN 1
PROCEDURE Main()
LOCAL o := Holder():New()
LOCAL r := o:Change()
? text, r
RETURN
