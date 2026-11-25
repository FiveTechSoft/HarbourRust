FUNCTION Main()
LOCAL n:=0
? Empty(NIL).AND.(++n>0),n
? !Empty(NIL).AND.(++n>0),n
? Empty(NIL).OR.(++n>0),n
? Empty(NIL)==.T.,Empty(NIL)!=.F.
? IIf(Empty(NIL),++n,99),n
DO WHILE Empty(NIL).AND.n<4
 n++
ENDDO
? n,Empty(NIL)
RETURN NIL
