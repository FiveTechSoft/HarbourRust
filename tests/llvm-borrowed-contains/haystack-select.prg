FUNCTION Main()
LOCAL n:=0,a:="ab"
? a$IIf(++n==1,"zab","bad"),n
? ""$IIf(++n==2,"abc",""),n
? Chr(0)$IIf(.T.,"x"+Chr(0),"")
? "中"$IIf(.T.,"é中",""),"long"$IIf(.T.,"x","long")
? !("absent"$IIf(.T.,"abc","absent"))
RETURN NIL
