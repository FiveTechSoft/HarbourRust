FUNCTION SortIt(a)
 ASort(a)
RETURN Len(a)
FUNCTION Main()
 LOCAL a:={7,2,9,1},b:={"pear","","apple"}
 ? SortIt(a),a[1],a[4]
 ? SortIt(b),b[1],b[3]
RETURN NIL
