procedure main()
   local h := "abcdef", n := "cd"
   if n $ h
      ? "yes"
   else
      ? "no"
   endif
   if "zz" $ h
      ? "bad"
   else
      ? "no2"
   endif
   ? n $ "x" + h
return
