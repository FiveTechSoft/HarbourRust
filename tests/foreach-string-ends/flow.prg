PROCEDURE Main()
 LOCAL e:="",s:="x",t:="abcdef",v:=NIL,i:=0
 FOR EACH v IN e
 ? "BAD",v:__enumIndex
 NEXT
 FOR i:=1 TO 67
 FOR EACH v IN s
 ? v:__enumIndex,v:__enumIsFirst,v:__enumIsLast
 NEXT
 NEXT
 FOR EACH v IN t
 IF v:__enumIsFirst
 ? "first",v
 LOOP
 ENDIF
 IF v:__enumIndex==4
 ? "exit",v,v:__enumIsLast
 EXIT
 ENDIF
 ? v:__enumIsFirst==v:__enumIsLast
 NEXT
RETURN
