PROCEDURE Main()
 LOCAL s:="",v:=NIL,i:=0
 FOR i:=0 TO 255
 s+=Chr(i)
 NEXT
 FOR EACH v IN s
 ? Asc(v),v:__enumIndex,v:__enumIsFirst,v:__enumIsLast
 NEXT
 s:="é"+Chr(0)+"路径"
 FOR EACH v IN s
 ? Asc(v),v:__enumIndex,v:__enumIsFirst,v:__enumIsLast
 NEXT
RETURN
