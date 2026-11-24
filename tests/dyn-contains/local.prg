PROCEDURE Main()
 LOCAL s:=NIL,i:=0,n:=0
 FOR i:=1 TO 163
  s:="Lu;Ll;"+Chr(0)+"x"
  IF "Lu" $ s
   n++
  ENDIF
  ? "" $ s,"LU" $ s,"u;" $ s,"x" $ s,"longer than haystack" $ s
  s:=""
  ? "Lu" $ s
 NEXT
 ? n,s
RETURN
