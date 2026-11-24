// Own MIT. Start/end order and repeated end evaluation remain unchanged.
STATIC n:=0
FUNCTION Mark(x)
 n+=1
 ? "mark",x,n
RETURN x+0
PROCEDURE Main()
 LOCAL i:=0,k:=0
 FOR k:=1 TO 37 STEP (3-2)
  FOR i:=Mark(1) TO Mark(4) STEP +(6/3)
   ? "body",i
  NEXT
  ? "done",i,n
  FOR i:=4 TO 1 STEP (3-1)
   ? "never",i
  NEXT
  ? "skip",i
 NEXT
RETURN
