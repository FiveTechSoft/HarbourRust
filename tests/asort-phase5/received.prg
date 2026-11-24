FUNCTION SortIt(a)
 ASort(a)
RETURN Len(a)
FUNCTION Main()
 LOCAL a:={1.25,-3,2.5},b
 b:=a
 ? SortIt(a),b[1],b[3]
RETURN NIL
