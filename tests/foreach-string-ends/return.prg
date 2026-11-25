PROCEDURE Main()
 LOCAL s:="abcdef",v:=NIL
 FOR EACH v IN s
 ? v:__enumIndex,v:__enumIsFirst,v:__enumIsLast
 IF v:__enumIndex==3
 RETURN
 ENDIF
 NEXT
RETURN
