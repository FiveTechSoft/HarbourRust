FUNCTION Main()
LOCAL n:=0,a:="ab"
? a==IIf(++n==1,"ab","x"),n
? ""==IIf(++n==2,"","x"),n
? "x "==IIf(.T.,"x","x "),"x"==IIf(.T.,"x ","x")
? Chr(0)==IIf(.T.,Chr(0),""),"é中"==IIf(.T.,"é中","")
? !("A"==IIf(.T.,"a","A")),"a"==IIf(.T.,"ab","a")
RETURN NIL
