PROCEDURE Main()
 LOCAL x:=NIL,y:=NIL,a:=Array(4),b:=Array(2),n:=0
 FOR EACH x IN a
  ? x:__enumIndex()
  IF x:__enumIndex()==2
   LOOP
  ENDIF
  FOR EACH y IN b
   ? x:__enumIndex(),y:__enumIndex()
   n++
   IF y:__enumIndex()==1
    EXIT
   ENDIF
  NEXT
 NEXT
 ? n,ValType(x),ValType(y)
 FOR EACH x IN hb_ATokens("a;b;;c",";")
  ? x,x:__enumIndex()
 NEXT
RETURN
