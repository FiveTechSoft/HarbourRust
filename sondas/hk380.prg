function main()
   local x := 0
   do while x < 10
      x := x + 1
      if x == 3
         return
      endif
   enddo
   ? "unreached"
return
