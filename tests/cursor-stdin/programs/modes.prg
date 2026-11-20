FUNCTION Main()
 LOCAL i,n
 FOR i:=-2 TO 7
  n:=SetCursor(i)
  ? i,n,SetCursor()
 NEXT
 ? SetCursor(9223372036854775807),SetCursor(),SetCursor(-9223372036854775807),SetCursor()
RETURN NIL
