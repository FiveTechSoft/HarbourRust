// Locals, statics, parameters and block parameters may use the names of
// runtime helpers (report against 0.11.4: `LOCAL month` was rejected).
PROCEDURE Main()
   LOCAL month := 11, val := "x", date := 5, alloc := 1, free := 2, str := 7
   LOCAL b := {|year| year + 1 }
   STATIC len := 3
   ? month, val, date, alloc, free, str, len
   ? Val("12") + 1, Len("abcd"), Str(4)
   ? Eval(b, 2)
   ? f(4)
RETURN
FUNCTION f(day)
   LOCAL i
   FOR i := 1 TO 2
      day := day + i
   NEXT
RETURN day
