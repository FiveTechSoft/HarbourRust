function main()
   local s := Chr(255)
   local sum := 0
   local i
   for i := 1 to 10000000
      sum := sum + Asc(s)
   next
   ? sum
return
