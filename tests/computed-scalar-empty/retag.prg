PROCEDURE Main(c)
LOCAL i
FOR i:=1 TO 40
 c:=Upper("x")+Lower("Y")+Space(4)
 ? Empty(c),Len(c)
 c:=Chr(9)+Chr(13)+Chr(10)
 ? Empty(c)
NEXT
RETURN
