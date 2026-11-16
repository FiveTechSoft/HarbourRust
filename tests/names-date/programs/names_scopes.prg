PROCEDURE Main()
   LOCAL month := 4, str := 2
   ? Eval( {| month | month + 1 }, 8 ), month
   FOR str := 1 TO 3
      month += str
   NEXT
   ? month, str
RETURN
