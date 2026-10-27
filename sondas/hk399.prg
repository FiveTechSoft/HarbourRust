function main()
   local i
   local n := 0
   for i := 1 to 1000000
      if QQOut() == NIL
         n++
      endif
   next
   ? n
return
