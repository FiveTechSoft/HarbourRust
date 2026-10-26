function main()
   local x := 2
   do case
   case x == 1
      ? "one"
   case x == 2
      return
   otherwise
      ? "other"
   endcase
   ? "unreached"
return
