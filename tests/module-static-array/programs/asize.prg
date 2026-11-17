STATIC a := {1, {21, 22}, 3}
PROCEDURE Main()
   LOCAL b
   ASize(a, 5)
   ? len(a), a[4], a[5], valtype(a[4])
   b := a[2]
   ASize(a, 1)
   ? len(a), a[1]
   ? len(b), b[1], b[2]
   ASize(a, 3)
   ? len(a), a[2], a[3]
   a[2] := 9
   ASize(a, 2)
   ? len(a), a[2]
   RETURN
