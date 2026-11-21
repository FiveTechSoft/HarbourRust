PROCEDURE MAIN()
local p := "999.99"
local s := ""
local i := 0
local x := -2.5
local d
x := -2.5
? "[" + Transform(x, "@( " + p) + "]"
? "[" + Transform(12.345, p) + "]"
? "[" + Transform(x, "@X " + p) + "]"
? "[" + Transform("abc" + "def", "@!") + "]"
? "[" + Transform("abc", p) + "]"
? "[" + Transform(.T., "@R Y") + "]"
? "[" + Transform(5, "@L 999") + "]"
? "[" + Transform(0, "@Z 999") + "]"
? "[" + Transform(0.5, "@B .99") + "]"
? "[" + Transform(12, "@B 9999") + "]"
d := CToD("01/02/2026")
? "[" + Transform(d, "@E") + "]"
FOR i := 1 TO 2000
  s := Transform(i, "999,999")
  s := Transform("abc", "@R 99-9")
NEXT
? s
RETURN
