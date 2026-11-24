FUNCTION Main()
 LOCAL a:={2,"z","a","aa","",NIL}
 a:={"z","a","aa","","a","zzz"}
 ASort(a,NIL,NIL,{|x,y|QOut(x,y),x>y})
 ? a[1],a[2],a[3],a[4],a[5],a[6]
RETURN NIL
