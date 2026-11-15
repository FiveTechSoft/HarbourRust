procedure main()
   local c := "'ab' .AND. (1/0) < 2"
   ? "before"
   ? &(c)
   ? "after"
return
