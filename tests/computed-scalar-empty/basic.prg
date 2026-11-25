PROCEDURE Main(c)
? Empty(c),ValType(c)
c:=Upper(" ")+Lower("")
? Empty(c),ValType(c)
c:=Chr(9)+Space(2)
? Empty(c)
c:=hb_ps()+"x"
? Empty(c),c
c:=NIL
? Empty(c),ValType(c)
RETURN
