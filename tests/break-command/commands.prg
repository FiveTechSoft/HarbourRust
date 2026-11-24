// Own MIT. Command form only; no empty function call substitution.
FUNCTION Fail(x)
 BREAK x+1
RETURN NIL
PROCEDURE Work()
 LOCAL e:=NIL,i:=0
 FOR i:=1 TO 117
  BEGIN SEQUENCE
   BREAK
  RECOVER USING e
   ? "bare",ValType(e)
  END SEQUENCE
  BEGIN SEQUENCE
   BREAK "text"+" value"
  RECOVER USING e
   ? "string",e
  END SEQUENCE
  BEGIN SEQUENCE
   Fail(i)
  RECOVER USING e
   ? "number",e
  END SEQUENCE
  BEGIN SEQUENCE
   BREAK NIL
  RECOVER USING e
   ? "nil",ValType(e)
  END SEQUENCE
  BEGIN SEQUENCE
   BREAK
  RECOVER
   ? "discard"
  END SEQUENCE
 NEXT
RETURN
PROCEDURE Main()
 Work()
RETURN
